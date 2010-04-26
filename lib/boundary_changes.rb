require File.expand_path(File.dirname(__FILE__) + '/timer')

module FindYourMP; end
module FindYourMP::BoundaryChanges
  
  include FindYourMP::Timer
  
  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')

  # RB hacked to point to local recent file
  BOUNDARY_FILE = "#{DATA_DIR}/pcd_pcon_aug_2009_uk_lu.txt"
  
  def create_new_constituencies_file
    tab = "\t"
    new_constituencies = []
    new_line = "\n"
    
    constituencies_file = "#{DATA_DIR}/new_constituencies.txt"
    
    start_timing
    
    if File.exist?(constituencies_file)
      cmd = "mv #{constituencies_file} #{constituencies_file}.#{Time.now.to_i.to_s}"
      puts cmd
      `#{cmd}`
    end
    
    constituencies = {}
    IO.foreach(BOUNDARY_FILE) do |line|
      ons_id = line[24..26]
      unless ons_id == '   '
        unless constituencies.has_key?("#{ons_id}")
          if line.length > 27
            constituency_name = line[27..line.length]
            unless constituency_name.strip == ""
              constituencies.merge!({"#{ons_id}" => "#{constituency_name.strip}"})
            end
          end
        end
      end
    end
    
    keys = constituencies.keys.sort
      
    line = []
    keys.each do |key|
      new_constituencies << key << tab << constituencies[key] << new_line
    end
    log_duration
    
    start_timing
    File.open(constituencies_file,'w') do |file|
      file.write(new_constituencies.join(''))
    end
    log_duration
  end
end