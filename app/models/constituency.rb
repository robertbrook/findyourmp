class Constituency < ActiveRecord::Base
  include ActionController::UrlWriter

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true

  has_many :postcodes
  has_many :postcode_districts
  has_many :messages
  validate :valid_email?

  class << self

    def all_constituencies
      all.select{|c| c.name != 'Example'}
    end

    def remove_quotes text
      unless text
        text = ""
      end
      text.strip[/^"?([^"]+)"?$/,1]
    end

    def load_tsv_line line
      parts = line.split("\t")

      constituency_name = remove_quotes(parts[0])
      member_name = remove_quotes(parts[1])
      member_party = remove_quotes(parts[2])
      member_bio_url = remove_quotes(parts[3])
      member_contact = remove_quotes(parts[4])
      member_website = remove_quotes(parts[5])
      member_contact = "" unless member_contact

      existing = Constituency.find_by_constituency_name(constituency_name)
      new_constituency = nil

      if existing
        non_matching = (existing.member_name != member_name || existing.member_party != member_party || existing.member_biography_url != member_bio_url)
        non_matching = non_matching || ( member_contact[/http:\/\//] ?
          (existing.member_requested_contact_url.to_s.strip != member_contact.to_s.strip) : (existing.member_email.to_s.strip != member_contact.to_s.strip) )
        if non_matching
          new_constituency = Constituency.new(existing.attributes)
          new_constituency.member_name = member_name
          new_constituency.member_party = member_party
          new_constituency.member_biography_url = member_bio_url
          if member_contact[/http:\/\//]
            new_constituency.member_requested_contact_url = member_contact
          else
            new_constituency.member_email = member_contact.chomp('.')
          end
          new_constituency.member_website = member_website
        end
        [existing, new_constituency]
      else
        [nil, nil]
      end
    end

    def find_all_constituency_and_member_matches term
      term = term.squeeze(' ').gsub('"','')
      constituencies = Constituency.find_all_name_or_member_name_matches(term)
      members = constituencies.clone

      if term[/[A-Z][a-z].*/]
        constituencies = constituencies.select { |c| c.name.include? term }
        members = members.select { |c| c.member_name.include? term }
      else
        constituencies = constituencies.select { |c| c.name.downcase.include? term.downcase }
        members = members.select { |c| c.member_name? && c.member_name.downcase.include?(term.downcase) }
      end

      constituencies = constituencies.sort_by(&:name)
      members = members.sort_by(&:member_name)

      return [constituencies, members]
    end

    def find_all_name_or_member_name_matches term
      term = term.squeeze(' ').gsub('"','')
      matches_name_or_member_name = %Q|name like "%#{term}%" or | +
          %Q|(member_name like "%#{term}%" and member_visible = 1)|
      constituencies = find(:all, :conditions => matches_name_or_member_name)
      constituencies.delete_if{|c| c.name == 'Example'}

      if case_sensitive(term)
        constituencies.delete_if do |c|
          !c.name.include?(term) && !c.member_name.include?(term)
        end
      end
      constituencies
    end

    def case_sensitive term
      term.gsub('"','')[/^([A-Z][a-z]+[ ]+)*([A-Z][a-z]+)$/] ? true : false
    end

    def find_by_constituency_name name
      name.gsub!(' - ','-')
      if name[/^(.+), City of$/]
        name = "City of #{$1}"
      end
      constituency = find_by_name(name)

      unless constituency
        name.gsub!('&', 'and')
        if name == "Regent's Park and Kensington North"
          name = "Regent's Park and North Kensington"
        end
        if name[/^(.+), The$/]
          name = "The #{$1}"
        end
        name.tr!('-', ' ')
        name.gsub!('ô','o')
        name.gsub!('and#244;', 'o')
        constituency = find_by_name(name)
      end

      unless constituency
        name.gsub!('St ', 'St. ')
        constituency = find_by_name(name)
      end

      unless constituency
        puts ""
        puts "not found: #{name}"
      end

      constituency
    end
  end

  def show_message_form?
    member_name? && member_email? && !member_requested_contact_url?
  end

  def code
    if ons_id.nil?
      ''
    elsif ons_id.length == 1
      "00#{ons_id}"
    elsif ons_id.length == 2
      "0#{ons_id}"
    else
      ons_id.to_s
    end
  end

  def no_sitting_member?
    (!member_name?) || (!member_visible)
  end

  def to_tsv_line
    %Q|"#{name}"\t"#{member_name}"\t"#{member_party}"\t"#{member_biography_url}"\t"#{member_email}"\t"#{member_website}"|
  end

  def to_json host, port
    if no_sitting_member?
      %Q|{"constituency": {"constituency_name": "#{name}", "member_name": "No sitting member", "member_party": "", "member_biography_url": "", "member_website": "", "uri": "#{object_url(host, port, "json")}" } }|
    else
      %Q|{"constituency": {"constituency_name": "#{name}", "member_name": "#{member_name}", "member_party": "#{member_party}", "member_biography_url": "#{member_biography_url}", "member_website": "#{member_website}", "uri": "#{object_url(host, port, "json")}" } }|
    end
  end

  def to_text host, port, format="txt"
    if no_sitting_member?
      %Q|constituency_name: #{name}\nmember_name: No sitting member\nmember_party: \nmember_biography_url: \nmember_website: \nuri: #{object_url(host, port, format)}|
    else
      %Q|constituency_name: #{name}\nmember_name: #{member_name}\nmember_party: #{member_party}\nmember_biography_url: #{member_biography_url}\nmember_website: #{member_website}\nuri: #{object_url(host, port, format)}|
    end
  end

  def to_csv host, port
    headers = 'constituency_name,member_name,member_party,member_biography_url,member_website,uri'
    values = to_csv_value(host, port)
    "#{headers}\n#{values}\n"
  end

  def to_csv_value host, port
    if no_sitting_member?
      %Q|"#{name}","No sitting member","","","","#{object_url(host, port, format, "csv")}"|
    else
      %Q|"#{name}","#{member_name}","#{member_party}","#{member_biography_url}","#{member_website}","#{object_url(host, port, "csv")}"|
    end
  end

  def to_output_yaml host, port
    "---\n#{to_text(host, port, "yaml")}"
  end

  def member_attribute_changed? attribute, constituency
    send(attribute).to_s.strip != constituency.send(attribute).to_s.strip
  end

  private
    def valid_email?
      unless member_email.blank?
        begin
          self.member_email = MessageMailer.parse_email(member_email).address
        rescue
          errors.add_to_base("Member email must be a valid email")
        end
      end
    end

    def object_url host, port, format=nil
      if port.to_s == "80"
        url_for :host=> host, :controller=>"constituencies", :action=>"show", :id => friendly_id, :format => format, :only_path => false
      else
        url_for :host=> host, :port=> port, :controller=>"constituencies", :action=>"show", :id => friendly_id, :format => format, :only_path => false
      end
    end
end
