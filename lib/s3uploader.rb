require 'aws/s3'

module FindYourMP; end
module FindYourMP::S3Uploader

  def send_backup(backup_file)
    unless File.exist?(backup_file)
      raise "Error, file to be backed up does not exist"
    end

    s3_conf = "#{RAILS_ROOT}/config/S3.yml"

    s3_config = File.open(s3_conf)
    s3_options = YAML.load(s3_config)
    
    puts "Encrypting file..."
    encrypted = encrypt_file(backup_file, s3_options[:key], s3_options[:alg], s3_options[:iv])
    puts encrypted
    puts ""
    
    puts "Uploading to S3..."
    upload_file(encrypted, s3_options[:bucket_name], s3_options[:bucket_key], s3_options[:bucket_secret])
    puts ""
    
    puts "Deleting encrypted file..."
    File.delete(encrypted)
    puts ""
    
    puts "Done!"
  end


  def symmetric_encryption(cipher, input, output)
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
  
  def symmetric_decryption(cipher, input, output)
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

  def encrypt_file(input, key, alg, iv)
    t = Time.now
    datetime = t.strftime("%Y%m%d%H%M%S")
    output = "#{datetime}_s3.bak"

    bf = OpenSSL::Cipher::Cipher.new(alg)
    bf.encrypt
    bf.key = key
    bf.iv = iv

    symmetric_encryption(bf, input, output)

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

    symmetric_decryption(bf, input, output)
    
    return output
  end

  def upload_file(file, bucket, key, secret)
     AWS::S3::Base.establish_connection!(
         :access_key_id     => key,
         :secret_access_key => secret
     )

     AWS::S3::S3Object.store(file, open(file), bucket)
  end
end