require 'aws/s3'

module FindYourMP; end
module FindYourMP::S3Uploader

  def send_backup(backup_file)
    unless File.exist?(backup_file)
      raise "Error, file to be backed up does not exist"
    end

    backup_path = "#{RAILS_ROOT}/db/backup"
    s3_conf = "#{RAILS_ROOT}/config/S3.yml"

    s3_config = File.open(s3_conf)
    s3_options = YAML.load(s3_config)

    system("cp #{backup_file} #{backup_path}")
    backup_file_path = File.dirname(backup_file)
    backup_file_name = backup_file.gsub(backup_file_path + '/', '')
    
    puts "Encrypting file..."
    encrypted = encrypt_file(backup_file_name, backup_path, s3_options[:alg], 'fymp-public.pem')
    puts encrypted
    puts ""
        
    data_file_name = encrypted.gsub(backup_path + '/', '')
    send_file_name = data_file_name.gsub('.bak', '.tar.gz')
    key_file_name = data_file_name.gsub('.bak', '_key.txt')
    iv_file_name = data_file_name.gsub('.bak', '_iv.txt')
    
    puts "Compressing files..."
    system("tar -C #{backup_path} -cvzf #{backup_path}/#{send_file_name} #{data_file_name} #{key_file_name} #{iv_file_name}")
    puts ""
    
    puts "Deleting temporary files..."
    system("rm #{backup_path}/#{data_file_name}; rm #{backup_path}/#{key_file_name}; rm #{backup_path}/#{iv_file_name}; rm #{backup_path}/#{backup_file}")
    puts ""
    
    puts "Uploading to S3..."
    upload_file("#{backup_path}/#{send_file_name}", s3_options[:bucket_name], s3_options[:bucket_key], s3_options[:bucket_secret])
    puts ""
    
    puts "Deleting backup file..."
    system("rm #{backup_path}/#{send_file_name}")
    puts ""
    
    puts "Done!"
  end


  def symmetric_file_encryption(cipher, input, output)
    cipher.encrypt
    size = File.size(input)
    blocks = size / 16
    
    File.open(output,'w') do |enc|
      File.open(input) do |file|
        for i in 1..blocks-1
          block = file.read(16)
          enc << cipher.update(block)
        end

        if size%16 > 0
          pad_size = 16 - size%16
          padding = ""
          padding = padding.ljust(pad_size+1, " ")
          
          block = file.read() << padding
          enc << cipher.update(block)
          
          enc << cipher.final
          enc << pad_size.to_s(base=16)
        end
      end
    end
  end
  
  def symmetric_file_decryption(cipher, input, output)
    cipher.decrypt
    size = File.size(input)
    blocks = size / 16
    
    if size%16 > 0
      blocks = blocks - 1
    end
    
    File.open(output,'w') do |dec|
      File.open(input) do |file|        
        for i in 1..blocks
          block = file.read(16)
          dec << cipher.update(block)
        end
        
        if size%16 >0
          last_bit_crypted = file.read(16)
          last_bit_plain = cipher.update(last_bit_crypted)
          
          pad_size = file.read().hex
          pad_size+=1
          dec << last_bit_plain[0..-pad_size]
        end
      end
    end
  end

  def asymmetric_encryption(keyfile, plain_text)
    public_key_file = keyfile
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))  
   
    encrypted = public_key.public_encrypt(plain_text)
    encrypted
  end
  
  def asymmetric_decryption(keyfile, password, encrypted)
    private_key_file = keyfile 
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file),password)  

    decrypted = private_key.private_decrypt(encrypted)
    decrypted
  end

  def encrypt_file(input, folder, alg, pem_file)
    t = Time.now
    datetime = t.strftime("%Y%m%d%H%M%S")
    
    output = "#{folder}/#{datetime}_s3.bak"

    cipher = OpenSSL::Cipher::Cipher.new(alg)
    cipher.encrypt
    cipher.key = cipher_key = cipher.random_key
    cipher.iv = cipher_iv = cipher.random_iv

    symmetric_file_encryption(cipher, input, output)

    key_file = "#{folder}/#{datetime}_s3_key.txt"
    File.open(key_file,'w') do |file|
      file << asymmetric_encryption(pem_file, cipher_key)
    end
    
    iv_file = "#{folder}/#{datetime}_s3_iv.txt"
    File.open(iv_file,'w') do |file|
      file << asymmetric_encryption(pem_file, cipher_iv)
    end

    return output
  end
  
  def decrypt_file(input)
    s3_conf = "#{RAILS_ROOT}/config/S3.yml"

    s3_config = File.open(s3_conf)
    s3_options = YAML.load(s3_config)
    
    alg = s3_options[:alg]
    key = s3_options[:key]
    iv = s3_options[:iv]
    
    t = Time.now
    datetime = t.strftime("%Y%m%d%H%M%S")
    output = input.gsub(".bak", ".decrypted")

    bf = OpenSSL::Cipher::Cipher.new(alg)
    bf.decrypt
    bf.key = key
    bf.iv = iv

    symmetric_file_decryption(bf, input, output)
    
    return output
  end

  def upload_file(file, bucket, key, secret)
     AWS::S3::Base.establish_connection!(
         :access_key_id     => key,
         :secret_access_key => secret
     )

     stored_file_path = File.dirname(file)
     stored_file = file.gsub(stored_file_path + '/', '')
     AWS::S3::S3Object.store(stored_file, open(file), bucket)
  end
end