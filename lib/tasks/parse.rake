data = File.expand_path(File.dirname(__FILE__) + '/../../data')
data_file = "#{data}/NSPDC_AUG_2008_UK_100M.txt"
postcode_file = "#{data}/postcodes.txt"
constituency_file = "#{data}/Westminster Parliamentary Constituency names and codes UK as at 05_05.txt"
member_file = "#{data}/ConstituencyToMember.txt"
postcode_sql = "#{data}/postcodes.sql"

namespace :fymp do

  desc "Populate data for members in DB"
  task :members => :environment do
    unless File.exist?(member_file)
      $stderr.puts "Data file not found: #{member_file}"
    else
      Member.delete_all

      IO.foreach(member_file) do |line|
        begin
          parts = line.split("\t")
          constituency_name = parts[0].strip
          member_name = parts[1].strip
          vacant = member_name == 'Vacant'

          if vacant
            $stderr.puts "Constituency is vacant: #{constituency_name}"
          else
            member_name = member_name.split('(')[0].strip
            constituency = Constituency.find_by_constituency_name(constituency_name)
            if constituency
              member = Member.new :name => member_name, :constituency_id => constituency.id
              member.save!
            else
              $stderr.puts "Cannot create member for: #{line}"
            end
          end
        rescue Exception => e
          $stderr.puts "Cannot create member for: #{line} | #{e.to_s}"
        end
      end
    end
  end

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

  desc "Create cache of all postcode pages"
  task :make_cache => :environment do
    total = Postcode.count.to_f
    index = 0
    group_size = 1000

    include ActionView::Helpers::DateHelper
    require 'open-uri'
    offset = index * group_size

    TEMPLATE = %Q|<html>
  <head>
    <title>Find your constituency</title>
    <style>body {font-size:2em;margin: 5% 10%;} #search input {font-size:1.5em;} a {text-decoration:none;}</style>
  </head>
  <body>
    <div id='search'>
      <form action="/" method="get">
        <input id="postcode" name="postcode" type="text" value="" />
        <input name="commit" type="submit" value="SEARCH" />
      </form>
    </div>|
TEMPLATE2 = %Q|    <p style='float: right'>|
TEMPLATE3 = %Q|    </p>
  </body>
</html>|

    Dir.mkdir("public/postcodes") unless File.exist?("public/postcodes")
    start_timing
    while offset < total
      postcodes = Postcode.find(:all, :offset => offset, :limit => group_size, :include => {:constituency => :member})
      postcodes.each do |postcode|
        html = [TEMPLATE]
        html << %Q|    <p>POSTCODE<br/><strong>#{postcode.code_with_space}</strong></p>|
        html << %Q|    <p>CONSTITUENCY<br/><strong>#{postcode.constituency_name} (#{postcode.constituency_id})</strong></p>|
        if postcode.member_name
          html << "<p>MEMBER<br/><strong>#{postcode.member_name}</strong></p>"
        else
          html << "<p>NO RECORDED MEMBER</p>"
        end
        html << TEMPLATE2
        html << %Q|      <a href="/postcodes/#{postcode.code}.xml">XML</a>|
        html << %Q|      <a href="/postcodes/#{postcode.code}.json">JSON</a>|
        html << %Q|      <a href="/postcodes/#{postcode.code}.js">JS</a>|
        html << %Q|      <a href="/postcodes/#{postcode.code}.csv">CSV</a>|
        html << %Q|      <a href="/postcodes/#{postcode.code}.txt">TEXT</a>|
        html << %Q|      <a href="/postcodes/#{postcode.code}.yaml">YAML</a>|
        html << TEMPLATE3
        dir = "public/postcodes/#{postcode.code[0..1]}"
        Dir.mkdir(dir) unless File.exist?(dir)
        File.open("#{dir}/#{postcode.code}.html", 'w') { |f| f.write(html.join("\n")) }
      end
      index = index.next
      offset = index * group_size
      percentage_complete = offset / total
      log_duration percentage_complete
    end
  end

  desc "Populate data for postcode and constituency ID in DB"
  task :populate => :environment do
    unless File.exist?(postcode_file)
      $stderr.puts "Data file not found: #{postcode_file}, try running rake fymp:parse"
    else
      start_timing
      post_codes = []
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
          # Postcode.import columns, post_codes
          post_codes.each do |codes|
            Postcode.create :code => codes[0], :constituency_id => codes[1]
          end
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
