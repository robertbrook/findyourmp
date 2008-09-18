data = File.expand_path(File.dirname(__FILE__) + '/../../data')
data_file = "#{data}/NSPDC_AUG_2008_UK_100M.txt"
postcode_file = "#{data}/postcodes.txt"
constituency_file = "#{data}/Westminster Parliamentary Constituency names and codes UK as at 05_05.txt"
postcode_sql = "#{data}/postcodes.sql"

namespace :fymp do

  desc "Populate data for constituencies in DB"
  task :constituencies => :environment do
    unless File.exist?(constituency_file)
      $stderr.puts "Data file not found: #{constituency_file}"
    else
      Constituency.delete_all

      IO.foreach(constituency_file) do |line|
        constituency_id = line[0..2]
        constituency_name = line[3..(line.length-1)].strip
        constituency = Constituency.new :name=>constituency_name
        constituency.id = constituency_id
        constituency.save!
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

      include ActionView::Helpers::DateHelper

      IO.foreach(postcode_file) do |line|
        code = line[0..6].tr(' ','')
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
      estimated_remaining = estimated_time - duration
      due = (Time.now + estimated_remaining).strftime('%I:%M%p').downcase
      estimated_remaining = estimated_remaining.seconds.ago
      puts "#{time_ago_in_words(estimated_remaining).capitalize} remaining, due to complete about #{due}."
    else
      puts "duration: #{duration}"
    end
  end
end
