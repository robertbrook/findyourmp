data = File.expand_path(File.dirname(__FILE__) + '/../../data')
date_file = "#{data}/NSPDC_AUG_2008_UK_100M.txt"

namespace :fymp do

  desc "Parse data file for postcode and constituency ID *only*"
  task :parse do
    unless File.exist?(date_file)
      $stderr.puts "Data file not found: #{date_file}"
    else
      start = Time.now
      post_codes = []
      blank_date = '      '
      blank_code = '   '
      new_line = "\n"
      space = ' '

      IO.foreach(date_file) do |line|
        termination_date = line[29..34]
        if termination_date == blank_date
          consistuency_code = line[62..64]
          unless consistuency_code == blank_code
            post_codes << line[0..6] << space << consistuency_code
            post_codes << new_line
          end
        end
      end
      duration = Time.now - start
      puts "duration: #{duration}"

      start = Time.now
      File.open("#{data}/postcodes.txt",'w') do |file|
        file.write(post_codes.join(''))
      end
      duration = Time.now - start
      puts "duration: #{duration}"
    end
  end
end
