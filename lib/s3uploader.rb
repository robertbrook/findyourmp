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

  def encrypt_file(input, key, alg, iv)
    size = File.size(input)
    blocks = size / 16

    t = Time.now
    datetime = t.strftime("%Y%m%d%H%M%S")
    output = "#{datetime}_s3.bak"

    bf = OpenSSL::Cipher::Cipher.new(alg)
    bf.encrypt
    bf.key = key
    bf.iv = iv

    File.open(output,'w') do |enc|
      File.open(input) do |f|
        for i in 1..blocks-1
          r = f.read(16)
          cipher = bf.update(r)
          enc << cipher
        end

        if size%16 > 0
          puts size%16
          pad_size = 16 - size%16
          padding = ""
          padding = padding.ljust(pad_size+1, " ")
          
          r = f.read() << padding
          cipher = bf.update(r)
          enc << cipher
          
          enc << bf.final
          enc << pad_size.to_s(base=16)
        end
      end
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
    
    size = File.size(input)
    blocks = size / 16

    if size%16 > 0
      blocks = blocks - 1
    end

    t = Time.now
    datetime = t.strftime("%Y%m%d%H%M%S")
    output = input.gsub(".bak", ".decrypted")

    bf = OpenSSL::Cipher::Cipher.new(alg)
    bf.decrypt
    bf.key = key
    bf.iv = iv

    File.open(output,'w') do |dec|
      File.open(input) do |f|        
        for i in 1..blocks
          r = f.read(16)
          cipher = bf.update(r)
          dec << cipher
        end
        
        if size%16 >0
          last_bit = f.read(16)
          cipher = bf.update(last_bit)
          
          pad_size = f.read().hex
          pad_size+=1
          dec << cipher[0..-pad_size]
        end
      end
    end
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