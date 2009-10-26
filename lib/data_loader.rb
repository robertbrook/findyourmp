require File.expand_path(File.dirname(__FILE__) + '/timer')

module FindYourMP; end
module FindYourMP::DataLoader

  include FindYourMP::Timer

  DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../data')
  MEMBER_FILE = "#{DATA_DIR}/FYMP_all.txt"
  CONSTITUENCY_FILE = "#{DATA_DIR}/constituencies.txt"

  POSTCODE_FILE = "#{DATA_DIR}/postcodes.txt"

  def diff_postcodes old_file, new_file
    old_postcodes = "#{DATA_DIR}/old_postcodes.txt"
    new_postcodes = "#{DATA_DIR}/new_postcodes.txt"

    parse_postcodes old_file, old_postcodes
    parse_postcodes new_file, new_postcodes

    diff_file = "#{DATA_DIR}/diff_postcodes.txt"
    if File.exist?(diff_file)
      cmd = "mv #{diff_file} #{diff_file}.#{Time.now.to_i.to_s}"
      puts cmd
      `#{cmd}`
    end

    cmd = "diff #{old_postcodes} #{new_postcodes} > #{diff_file}"
    puts cmd
    `#{cmd}`
  end

  def determine_postcode_changes
    diff_file = "#{DATA_DIR}/diff_postcodes.txt"

    if file_not_found(diff_file)
      puts "Generate or upload #{diff_file}"
      return
    end

    to_delete = {}
    to_create = {}
    to_update = {}

    IO.foreach(diff_file) do |line|
      parts = line.strip.split(' ')
      indicator = parts[0]

      if indicator[/(<|>)/]
        ons_id = parts.pop
        postcode = parts.join(' ').sub(indicator, '').strip
        if indicator == '<'
          to_delete[postcode] = ons_id
        elsif indicator == '>'
          to_create[postcode] = ons_id
        end
      end
    end
    to_create.keys.each do |postcode|
      if to_delete.delete(postcode)
        ons_id = to_create.delete(postcode)
        to_update[postcode] = ons_id
      end
    end
    puts 'to_delete ' + to_delete.size.to_s + ' e.g. ' + to_delete.to_a.first.inspect
    puts 'to_update ' + to_update.size.to_s + ' e.g. ' + to_update.to_a.first.inspect
    puts 'to_create ' + to_create.size.to_s + ' e.g. ' + to_create.to_a.first.inspect

    puts 'checking we have constituencies... '

    (to_delete.values + to_update.values + to_create.values).flatten.uniq.each do |ons_id|
      unless ignore_ons_id?(ons_id)
        constituency = Constituency.find_by_ons_id(ons_id)
        raise "unexpected constituency id #{ons_id}" unless constituency
      end
    end
    puts 'all constituencies found'

    return [to_delete, to_update, to_create]
  end

  def update_postcodes
    to_delete, to_update, to_create = determine_postcode_changes
    # puts "Update database? y/n"
    # answer = STDIN.gets
    # if answer.strip == 'y'
      do_postcode_update to_delete, to_update, to_create
    # else
      # puts 'exiting without database update'
    # end
  end

  def ignore_ons_id?(ons_id)
    ons_id == '800' || ons_id == '900'
  end

  def analyze_postcode_update
    to_delete, to_update, to_create = determine_postcode_changes

    already_deleted = []
    to_delete.each do |postcode, ons_id|
      already_deleted << [postcode, ons_id] unless Postcode.exists?(:code => postcode.sub(' ',''))
    end
    puts "TO DELETE, BUT ALREADY DELETED: #{already_deleted.size}"

    missing_updates = []
    to_update.each do |postcode, ons_id|
      missing_updates << [postcode, ons_id] unless Postcode.exists?(:code => postcode.sub(' ',''))
    end
    puts "TO UPDATE, BUT MISSING FROM DB: #{missing_updates.size}"

    already_there = []
    to_create.each do |postcode, ons_id|
      already_there << [postcode, ons_id] if Postcode.exists?(:code => postcode.sub(' ',''))
    end
    puts "TO CREATE, BUT ALREADY IN DB: #{already_there.size}"
  end

  def do_postcode_update to_delete, to_update, to_create
    puts 'do_postcode_update...'
    total = (to_delete.size + to_update.size + to_create.size).to_f
    count = 0
    include ActionView::Helpers::DateHelper
    start_timing

    to_delete.each do |postcode, ons_id|
      if post_code = Postcode.find_by_code(postcode.sub(' ',''))
        if ManualPostcode.find_by_code(postcode.sub(' ',''))
          puts "  (ignoring manually added postcode - #{postcode})"
        else
          post_code.destroy
          count = count.next
          log_duration count / total
        end
      else
        warn "cannot delete postcode, as it was not in database: #{postcode}"
      end
    end
    to_update.each do |postcode, ons_id|
      post_code = Postcode.find_by_code(postcode.sub(' ',''))

      if post_code
        unless ignore_ons_id?(ons_id)
          constituency = Constituency.find_by_ons_id(ons_id)
          if constituency.nil?
            raise "cannot update postcode, as constituency was not in database: #{postcode} #{ons_id}"
          end
        end

        if BlacklistedPostcode.find_by_code postcode.sub(' ','')
          puts "  (deleting blacklisted postcode - #{postcode})"
          post_code.destroy
        else
          post_code.ons_id = ons_id.strip.to_i
          if constituency
            post_code.constituency_id = constituency.id
          else
            post_code.constituency_id = nil
          end
          post_code.save
        end

        count = count.next
        log_duration count / total
      else
        raise "cannot update postcode, as it was not in database: #{postcode} #{ons_id}"
      end
    end

    to_create.each do |postcode, ons_id|
      begin
        if Postcode.exists?(:code => postcode.sub(' ',''))
          warn 'exists ' + postcode
        elsif BlacklistedPostcode.find_by_code postcode.sub(' ','')
          puts "  (ignoring blacklisted postcode - #{postcode})"
        else
          Postcode.create! :code => postcode.sub(' ',''), :ons_id => ons_id.strip.to_i
        end
      rescue Exception => e
        raise e
      end
      count = count.next
      log_duration count / total
    end
    log_duration
  end

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

  def parse_postcodes source_file, output_file=POSTCODE_FILE
    return if file_not_found(source_file)
    start_timing
    blank_date = '      '
    blank_code = '   '
    new_line = "\n"
    space = ' '
    post_codes = []

    IO.foreach(source_file) do |line|
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
    File.open(output_file,'w') do |file|
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

  def load_manual_postcodes
    manual_codes = ManualPostcode.all
    manual_codes.each do |manual_code|
      Postcode.create :code => manual_code.code, :constituency_id => manual_code.constituency_id, :ons_id => manual_code.ons_id
    end
  end

  private

    def load_codes(post_codes)
      post_codes.each do |codes|
        if BlacklistedPostcode.find_by_code codes[0]
          puts "  (ignoring blacklisted postcode - #{codes[0]})"
        else
          Postcode.create :code => codes[0], :ons_id => codes[1]
        end
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
