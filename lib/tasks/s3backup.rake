require File.expand_path(File.dirname(__FILE__) + '/../s3uploader.rb')

include FindYourMP::S3Uploader

namespace :fymp do
  
  desc "Backup the database to a file and send to S3"
  task :backup_db_s3 do  
    user = ENV['username']
    password = ENV['password']
    path = ENV['path']
    
    unless password && user && path
      puts 'must supply username, password and path to run the db backup'
      puts 'USAGE: rake fymp:db_backup username=user password=pass path=/directory/you/want/the/output/file/to/go'
    else
      backup_file = db_backup(user, password, path, RAILS_ENV)
      backup_to_s3(backup_file)
    end
  end

  desc "Decrypt"
  task :decrypt_file do
    crypted_file = ENV['filename']
    
    unless crypted_file
      puts 'must supply file to decrypt'
      puts 'USAGE: rake fymp:decrypt_file filename=/path/and/filename.bak'
    else
      decrypt_data(crypted_file)
    end
  end
  
  def db_backup(user, password, path, env)    
    unless password && user && path
      puts 'must supply username, password and path to run the db backup'
      puts 'USAGE: rake fymp:db_backup username=user password=pass path=/directory/you/want/the/output/file/to/go'
    else
      if path.last == "/"
        path = path.chop
      end
      
      t = Time.now
      datetime = t.strftime("%Y%m%d%H%M%S")

      outfile = "#{path}/findyourmp_#{datetime}.bak"
      
      puts ""
      puts "backing up database to #{outfile} ..."
      unless password.blank?
        system("mysqldump findyourmp_#{env} --user=#{user} --password=#{password} > #{outfile}")
      else
        system("mysqldump findyourmp_#{env} --user=#{user} > #{outfile}")
      end
      puts ""
            
      return outfile
    end
  end  
  
  def backup_to_s3(backup_file)    
    unless backup_file
      puts 'must supply backupfile to send to S3'
      puts 'USAGE: rake fymp:backup_to_S3 backupfile=/full/path/and/filename.bak'
    else
      unless File.exist?(backup_file)
        puts "ERROR: file #{backup_file} does not exist. Aborting"
      else
        send_backup(backup_file)
      end
    end
  end
end