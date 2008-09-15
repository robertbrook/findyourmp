data = File.expand_path(File.dirname(__FILE__) + '/../../data')
data_file = "#{data}/NSPDC_AUG_2008_UK_100M.txt"
postcode_file = "#{data}/postcodes.txt"
postcode_sql = "#{data}/postcodes.sql"

namespace :fymp do

  task :make_sql do
    unless File.exist?(postcode_file)
      $stderr.puts "Data file not found: #{postcode_file}, try running rake fymp:parse"
    else
      start_timing
      post_codes = []

      total = post_codes.size.to_f
      index = 0
      groups = 0
      group_size = 1000
      puts 'saving data to sql dump'

      columns = [:code, :constituency_id]
      total = `cat #{postcode_file} | wc -l`
      total = total.strip.to_f

      File.open(postcode_sql, 'w') do |file|
        IO.foreach(postcode_file) do |line|
          code = line[0..6]
          constituency_id = line[8..10]
          post_codes << %Q[INSERT INTO "postcodes" VALUES(1,'#{code}',#{constituency_id});]
          index = index.next
          if (index % group_size) == 0
            file.write(post_codes.join("\n"))
            groups = groups.next
            percentage_complete = (group_size * groups) / total
            log_duration percentage_complete
            post_codes = []
          end
        end
      end
    end
  end

  desc "Populate data for postcode and constituency ID in DB"
  task :populate => :environment do
    unless File.exist?(postcode_file)
      $stderr.puts "Data file not found: #{postcode_file}, try running rake fymp:parse"
    else
      start_timing
      post_codes = []

      total = post_codes.size.to_f
      index = 0
      groups = 0
      group_size = 1000
      puts 'saving data to db'

      Postcode.delete_all
      columns = [:code, :constituency_id]
      total = `cat #{postcode_file} | wc -l`
      total = total.strip.to_f

      IO.foreach(postcode_file) do |line|
        code = line[0..6]
        constituency_id = line[8..10]
        post_codes << [code, constituency_id]
        index = index.next
        if (index % group_size) == 0
          Postcode.import columns, post_codes
          groups = groups.next
          percentage_complete = (group_size * groups) / total
          log_duration percentage_complete
          post_codes = []
        end
      end
    end
  end

  desc "Parse data file for postcode and constituency ID *only*"
  task :parse do
    unless File.exist?(data_file)
      $stderr.puts "Data file not found: #{data_file}"
    else
      start_timing
      post_codes = []
      blank_date = '      '
      blank_code = '   '
      new_line = "\n"
      space = ' '

      IO.foreach(data_file) do |line|
        termination_date = line[29..34]
        if termination_date == blank_date
          consistuency_code = line[62..64]
          unless consistuency_code == blank_code
            post_codes << line[0..6] << space << consistuency_code
            post_codes << new_line
          end
        end
      end
      log_duration

      start_timing
      File.open(postcode_file,'w') do |file|
        file.write(post_codes.join(''))
      end
      log_duration
    end
  end

  def start_timing
    @start = Time.now
  end

  def log_duration percentage_complete=nil
    duration = Time.now - @start
    if percentage_complete
      estimated_time = (duration / percentage_complete)
      estimated_remaining = ((estimated_time - duration) / 60).to_i
      if estimated_remaining > 60
        estimated_remaining = (estimated_remaining * 10 / 60) / 10.0
        estimated_remaining = "#{estimated_remaining} hours"
      else
        estimated_remaining = "#{estimated_remaining} mins"
      end
      puts "remaining: #{estimated_remaining}"
    else
      puts "duration: #{duration}"
    end
  end
end
