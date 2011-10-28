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


  # used to compare a postcodes.txt file generated from the August '09 data
  # with the pcd_pcon_aug_2009_uk_lu.txt file to create a new postcodes.txt
  # file (in the example given, saved as new_postcodes.txt)
  def parse_new_postcodes original_file, new_file, output_file=POSTCODE_FILE
    return if file_not_found(original_file)
    return if file_not_found(new_file)
    start_timing

    blank_date = '      '
    blank_code = '   '
    new_line = "\n"
    space = ' '
    post_codes = []

    new_data = File.open(new_file)

    IO.foreach(original_file) do |line|
      #ignore blank lines, Guernsey and Isle of Man postcodes
      unless line == "" || line[8..10] == "800" || line[8..10] == "900"
        orig_post_code = line[0..6]
        post_code = ""
        while (post_code != orig_post_code)
          data = new_data.readline
          post_code = data[0..6]
          constituency_code = data[24..26]
        end

        post_codes << post_code << space << constituency_code
        post_codes << new_line
      end
    end
    log_duration

    start_timing
    File.open(output_file,'w') do |file|
      file.write(post_codes.join(''))
    end
    log_duration
  end
end