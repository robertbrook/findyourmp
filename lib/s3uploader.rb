require File.expand_path(File.dirname(__FILE__) + '/encryption')

require 'aws/s3'

module FindYourMP; end
module FindYourMP::S3Uploader
  
  include FindYourMP::Encryption
  
  def call_cleanup(max_size)
    s3_conf = "#{RAILS_ROOT}/config/s3.yml"
    
    unless File.exist?(s3_conf)
      raise "Error, config file not found"
    end
    
    s3_config = File.open(s3_conf)
    s3_options = YAML.load(s3_config)
    
    cleanup_files(s3_options[:bucket_name], s3_options[:bucket_key], s3_options[:bucket_secret], max_size)
  end
  
  def db_backup(path, env)    
    if path.last == "/"
      path = path.chop
    end
    
    s3_conf = "#{RAILS_ROOT}/config/s3.yml"
    
    unless File.exist?(s3_conf)
      raise "Error, config file not found"
    end
    
    s3_config = File.open(s3_conf)
    s3_options = YAML.load(s3_config)
      
    t = Time.now
    datetime = t.strftime("%Y%m%d%H%M%S")

    outfile = "#{path}/findyourmp_#{datetime}.bak"
    
    puts ""
    puts "backing up database to #{outfile} ..."
    unless s3_options[:db_password].blank?
      system("mysqldump findyourmp_#{env} --user=#{s3_options[:db_user]} --password=#{s3_options[:db_password]} > #{outfile}")
    else
      system("mysqldump findyourmp_#{env} --user=#{s3_options[:db_user]} > #{outfile}")
    end
    puts ""
          
    return outfile
  end

  def send_backup(backup_file)
    unless File.exist?(backup_file)
      raise "Error, file to be backed up does not exist"
    end

    backup_path = "#{RAILS_ROOT}/db/backup"
    s3_conf = "#{RAILS_ROOT}/config/s3.yml"
    pem_file = "#{RAILS_ROOT}/config/fymp-public.pem"
    
    unless File.exist?(pem_file)
      raise "Error, public key not found - cannot encrypt backup data"
    end
    
    unless File.exist?(s3_conf)
      raise "Error, config file not found"
    end

    s3_config = File.open(s3_conf)
    s3_options = YAML.load(s3_config)

    system("cp #{backup_file} #{backup_path}")
    backup_file_path = File.dirname(backup_file)
    backup_file_name = backup_file.gsub(backup_file_path + '/', '')
    
    t = Time.now
    datetime = t.strftime("%Y%m%d%H%M%S")
        
    outfile = "#{backup_path}/findyourmp_#{datetime}_s3.bak"
    compressed_file = "#{backup_path}/findyourmp_#{datetime}_s3.zip"
    
    puts "Compressing backup file"
    system("tar -C #{backup_path} -cvzf #{compressed_file} #{backup_file_name}")
    puts ""
    
    puts "Encrypting file..."
    puts "#{outfile}"
    encrypt_file(compressed_file, outfile, s3_options[:alg], pem_file)
    puts ""
        
    data_file_name = "findyourmp_#{datetime}_s3.bak"
    send_file_name = data_file_name.gsub('.bak', '.tar.gz')
    key_file_name = data_file_name.gsub('.bak', '_key.txt')
    iv_file_name = data_file_name.gsub('.bak', '_iv.txt')
    
    puts "Zipping files..."
    system("tar -C #{backup_path} -cvzf #{backup_path}/#{send_file_name} #{data_file_name} #{key_file_name} #{iv_file_name}")
    puts ""
    
    puts "Deleting temporary files..."
    system("rm #{backup_path}/#{data_file_name}; rm #{backup_path}/#{key_file_name}; rm #{backup_path}/#{iv_file_name}; rm #{backup_path}/#{backup_file}; rm #{compressed_file}")
    puts ""
    
    puts "Uploading to S3..."
    upload_file("#{backup_path}/#{send_file_name}", s3_options[:bucket_name], s3_options[:bucket_key], s3_options[:bucket_secret])
    puts ""
    
    puts "Deleting backup file..."
    system("rm #{backup_path}/#{send_file_name}")
    puts ""
    
    puts "Done!"
  end

  
  def decrypt_data(input)
    pem_file = "#{RAILS_ROOT}/config/fymp-private.pem"
    s3_conf = "#{RAILS_ROOT}/config/s3.yml"

    unless File.exist?(pem_file)
      raise "Error, private key not found - cannot decrypt the data"
    end
    
    unless File.exist?(s3_conf)
      raise "Error, config file not found"
    end

    s3_config = File.open(s3_conf)
    s3_options = YAML.load(s3_config)
    
    alg = s3_options[:alg]
    pass = s3_options[:password]
    output = input + ".decrypted.tar.gz"
    
    decrypt_file(input, output, alg, pass, pem_file)
    
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
  
  def cleanup_files(bucket, key, secret, max_size)
    AWS::S3::Base.establish_connection!(
         :access_key_id     => key,
         :secret_access_key => secret
    )
    backup_store = AWS::S3::Bucket.find(bucket)
    current_size = backup_store.objects.size
    max_size = max_size.to_i
    
    if current_size > max_size 
      files = []
      backup_store.each do |object|
        files << object.key
      end
      files.sort!
      files.reverse!
      while files.size > max_size
        AWS::S3::S3Object.delete files.last, bucket
        files.pop
      end
    end
  end
end