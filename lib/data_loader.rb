require File.expand_path(File.dirname(__FILE__) + '/timer')

module FindYourMP; end
module FindYourMP::DataLoader

  include FindYourMP::Timer

  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  MEMBER_FILE = "#{DATA_DIR}/FYMP_all.txt"
  CONSTITUENCY_FILE = "#{DATA_DIR}/constituencies.txt"

  SOURCE_POSTCODE_FILE = "#{DATA_DIR}/NSPDF_FEB_2009_UK_1M.txt"
  POSTCODE_FILE = "#{DATA_DIR}/postcodes.txt"
  
  UPMYSTREET_FILE = "#{DATA_DIR}/upmystreetcodes.csv"

  def load_members member_file
    member_file = MEMBER_FILE unless member_file
    return if file_not_found(member_file)

    lines = []
    IO.foreach(member_file) do |line|
      line.strip!
      lines << line unless(line.blank? || line[/Constituency/])
    end

    lines.each do |line|
      begin
        parts = line.split("\t")
        constituency_name = parts[0].strip
        member_name = parts[1].strip

        if is_vacant?(member_name)
          log "Constituency is vacant: #{constituency_name}"
        else
          existing, updated_constituency = Constituency.load_tsv_line(line)
          if existing && updated_constituency
            existing.attributes = updated_constituency.attributes
            existing.save!
          elsif updated_constituency
            log "Cannot find constituency for member for line: #{line}"
          else
            # nothing to update
          end
        end
      rescue Exception => e
        log "Cannot set member_name on constituency for: #{line} | #{e.to_s}"
      end
    end
  end

  def load_constituencies
    return if file_not_found(CONSTITUENCY_FILE)
    Constituency.delete_all
    Slug.delete_all

    IO.foreach(CONSTITUENCY_FILE) do |line|
      constituency_id = line[0..2]
      constituency_name = line[3..(line.length-1)].strip
      Constituency.create :name=>constituency_name, :ons_id=>constituency_id
    end
  end
  
  def load_upmystreetcodes
     return if file_not_found(UPMYSTREET_FILE)
     UpMyStreetCode.delete_all

     IO.foreach(UPMYSTREET_FILE) do |line|
       parts = line.split(",")
       code = parts[0]
       constituency = parts[1].gsub('"','').gsub("\n",'')
       UpMyStreetCode.create :code=>code, :constituency=>constituency
     end
   end

  def parse_postcodes
    return if file_not_found(SOURCE_POSTCODE_FILE)
    start_timing
    blank_date = '      '
    blank_code = '   '
    new_line = "\n"
    space = ' '
    post_codes = []

    IO.foreach(SOURCE_POSTCODE_FILE) do |line|
      termination_date = line[29..34]
      if termination_date == blank_date
        consistuency_code = line[69..71]
        unless consistuency_code == blank_code
          post_code = line[0..6]
          post_codes << post_code << space << consistuency_code
          post_codes << new_line
        end
      end
    end
    log_duration

    start_timing
    File.open(POSTCODE_FILE,'w') do |file|
      file.write(post_codes.join(''))
    end
    log_duration
  end

  def load_postcodes group_size=1000
    return if file_not_found(POSTCODE_FILE)
    index = 0
    groups = 0
    puts 'saving data to db'

    Postcode.delete_all
    columns = [:code, :constituency_id]
    total = `cat #{POSTCODE_FILE} | wc -l`
    total = total.strip.to_f

    include ActionView::Helpers::DateHelper

    post_codes = []

    start_timing

    IO.foreach(POSTCODE_FILE) do |line|
      code = line[0..6].tr(' ','')
      constituency_id = line[8..10]
      post_codes << [code, constituency_id]
      index = index.next
      if (index % group_size) == 0
        load_codes(post_codes)
        groups = groups.next
        percentage_complete = (group_size * groups) / total
        log_duration percentage_complete
        post_codes = []
      end
    end

    # complete remaining
    load_codes(post_codes)
    log_duration 1.0
  end

  def load_postcode_districts
    PostcodeDistrict.delete_all
    sql = "SELECT SUBSTRING(code, 1, LENGTH(code)-3) " +
        "AS district, constituency_id " +
        "FROM postcodes " +
        "GROUP BY district, constituency_id;"
    districts =  PostcodeDistrict.find_by_sql(sql)
    districts.each do |district|
      PostcodeDistrict.create!(district.attributes)
    end
  end

  private

    def load_codes(post_codes)
      post_codes.each do |codes|
        Postcode.create :code => codes[0], :ons_id => codes[1]
      end
    end

    def is_vacant?(name)
      name == 'Vacant'
    end

    def log msg
      $stderr.puts msg
    end

    def file_not_found file_name
      if File.exist?(file_name)
        false
      else
        log "Data file not found: #{file_name}"
        true
      end
    end

end
