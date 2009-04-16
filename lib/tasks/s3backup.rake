require File.expand_path(File.dirname(__FILE__) + '/../s3uploader.rb')

include FindYourMP::S3Uploader

namespace :fymp do
  desc "Backup the database to a file"
  task :db_backup => :environment do
    user = ENV['username']
    password = ENV['password']
    path = ENV['path']
    
    unless password && user && path
      puts 'must supply username, password and path to run the db backup'
      puts 'USAGE: rake fymp:db_backup username=user password=pass path=/directory/you/want/the/output/file/to/go'
    else
      t = Time.now
      datetime = t.strftime("%Y%m%d%H%M%S")
      
      system("mysqldump findyourmp_#{RAILS_ENV} --user=#{user} --password=#{password} > #{path}/findyourmp_#{datetime}.bak")
      puts "file created: #{path}/findyourmp_#{datetime}.bak"
    end
  end
  
  desc "Send database backup file to S3"
  task :backup_to_S3 do
    backup_file = ENV['backupfile']
    
    unless backup_file
      puts 'must supply backupfile to send to S3'
      puts 'USAGE: rake fymp:backup_to_S3 backupfile=/full/path/and/filename.tar.gz'
    else
      unless File.exist?(backup_file)
        puts "ERROR: file #{backup_file} does not exist. Aborting"
      else
        send_file = backup_file #+ ".tar.gz"
        
        backupfile_path = File.dirname(backup_file)
        backupfile_name = backup_file.gsub(backupfile_path + '/', '')
        
        puts "Compressing file..."
        system("tar -C #{backupfile_path} -cvzf #{send_file} #{backupfile_name}")
        puts ""
        
        send_backup(send_file)
      end
    end
  end
  
  desc "Decrypt"
  task :decrypt_file do
    crypted_file = ENV['filename']
    
    decrypt_file(crypted_file)
  end
end