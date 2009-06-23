require File.expand_path(File.dirname(__FILE__) + '/../s3uploader.rb')

include FindYourMP::S3Uploader

namespace :fymp do
  
  desc "Backup the database to a file and send to S3"
  task :backup_db_s3 do  
    path = ENV['path']
    
    unless path
      puts 'must supply path to run the db backup'
      puts 'USAGE: rake fymp:db_backup path=/directory/you/want/the/output/file/to/go'
    else
      backup_file = db_backup(path, RAILS_ENV)
      backup_to_s3(backup_file)
    end
  end
  
  desc "Delete old backup files from S3"
  task :cleanup_db_backup do
    max_files = ENV['files_to_keep']
    
    unless max_files
      puts 'must supply number of files to keep'
      puts 'USAGE: rake fymp:cleanup_db_backup files_to_keep=42'
    else
      call_cleanup(max_files)
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