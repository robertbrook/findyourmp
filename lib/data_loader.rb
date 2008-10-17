require File.expand_path(File.dirname(__FILE__) + '/timer')

module FindYourMP; end
module FindYourMP::DataLoader

  include FindYourMP::Timer

  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  MEMBER_FILE = "#{DATA_DIR}/ConstituencyToMember.txt"
  CONSTITUENCY_FILE = "#{DATA_DIR}/Westminster Parliamentary Constituency names and codes UK as at 05_05.txt"

  SOURCE_POSTCODE_FILE = "#{DATA_DIR}/NSPDC_AUG_2008_UK_100M.txt"
  POSTCODE_FILE = "#{DATA_DIR}/postcodes.txt"

  def load_members
    return if file_not_found(MEMBER_FILE)
    Member.delete_all

    IO.foreach(MEMBER_FILE) do |line|
      begin
        parts = line.split("\t")
        constituency_name = parts[0].strip
        member_name = parts[1].strip

        if is_vacant?(member_name)
          log "Constituency is vacant: #{constituency_name}"
        else
          member_name = member_name.split('(')[0].strip
          constituency = Constituency.find_by_constituency_name(constituency_name)
          if constituency
            Member.create! :name => member_name, :constituency_id => constituency.id
          else
            log "Cannot create member for: #{line}"
          end
        end
      rescue Exception => e
        log "Cannot create member for: #{line} | #{e.to_s}"
      end
    end
  end

  def load_constituencies
    return if file_not_found(CONSTITUENCY_FILE)
    Constituency.delete_all

    IO.foreach(CONSTITUENCY_FILE) do |line|
      constituency_id = line[0..2]
      constituency_name = line[3..(line.length-1)].strip
      constituency = Constituency.new :name=>constituency_name
      constituency.id = constituency_id
      constituency.save!
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
        consistuency_code = line[62..64]
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

  def load_postcodes
    return if file_not_found(POSTCODE_FILE)
    start_timing
    index = 0
    groups = 0
    group_size = 1000
    puts 'saving data to db'

    Postcode.delete_all
    columns = [:code, :constituency_id]
    total = `cat #{POSTCODE_FILE} | wc -l`
    total = total.strip.to_f

    include ActionView::Helpers::DateHelper

    post_codes = []

    IO.foreach(POSTCODE_FILE) do |line|
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

  private

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
