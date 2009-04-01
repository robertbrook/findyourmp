class Constituency < ActiveRecord::Base
  include ActionController::UrlWriter

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true

  has_many :postcodes
  has_many :postcode_districts
  has_many :messages
  validate :valid_email?

  class << self

    def remove_quotes text
      text.strip[/^"?([^"]+)"?$/,1]
    end

    def load_tsv_line line
      parts = line.split("\t")

      constituency_name = remove_quotes(parts[0])
      member_name = remove_quotes(parts[1])
      member_party = parts[2].strip[/\((.+)\)/,1]
      member_bio_url = remove_quotes(parts[3])
      member_contact = remove_quotes(parts[4])
      member_contact = "" unless member_contact

      existing = Constituency.find_by_constituency_name(constituency_name)
      new_constituency = nil

      if existing
        non_matching = (existing.member_name != member_name || existing.member_party != member_party || existing.member_biography_url != member_bio_url)
        non_matching = non_matching || ( member_contact[/http:\/\//] ?
          (existing.member_requested_contact_url.to_s != member_contact.to_s) : (existing.member_email.to_s != member_contact.to_s) )
        if non_matching
          new_constituency = Constituency.new(existing.attributes)
          new_constituency.member_name = member_name
          new_constituency.member_party = member_party
          new_constituency.member_biography_url = member_bio_url
          if member_contact[/http:\/\//]
            new_constituency.member_requested_contact_url = member_contact
          else
            new_constituency.member_email = member_contact
          end
        end
        [existing, new_constituency]
      else
        [nil, nil]
      end
    end

    def find_all_name_or_member_name_matches term
      matches_name_or_member_name = %Q|name like "%#{term.squeeze(' ')}%" or | +
          %Q|member_name like "%#{term.squeeze(' ')}%"|
      constituencies = find(:all, :conditions => matches_name_or_member_name)

      if case_sensitive(term)
        constituencies.delete_if do |c|
          !c.name.include?(term) && !c.member_name.include?(term)
        end
      end
      constituencies
    end

    def case_sensitive term
      term[/^([A-Z][a-z]+[ ]+)*([A-Z][a-z]+)$/] ? true : false
    end

    def find_by_constituency_name name
      name.gsub!('St ', 'St. ')
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
    if ons_id < 10
      "00#{ons_id}"
    elsif ons_id < 100
      "0#{ons_id}"
    else
      ons_id.to_s
    end
  end

  def no_sitting_member?
    member_name.blank? || !member_visible
  end

  def to_tsv_line
    %Q|"#{name}"\t"#{member_name}"\t"(#{member_party})"\t"#{member_biography_url}"\t"#{member_email}"|
  end

  def to_json
    if no_sitting_member?
      %Q|{"constituency": {"constituency_name": "#{name}", "member_name": "No sitting member", "member_party": "", "member_biography_url": "", "member_website": "", "uri": "#{object_url("json")}" } }|
    else
      %Q|{"constituency": {"constituency_name": "#{name}", "member_name": "#{member_name}", "member_party": "#{member_party}", "member_biography_url": "#{member_biography_url}", "member_website": "#{member_website}", "uri": "#{object_url("json")}" } }|
    end
  end

  def to_text(format="txt")
    if no_sitting_member?
      %Q|constituency: #{name}\nmember_name: No sitting member\nmember_party: \nmember_biography_url: \nmember_website: \nuri: #{object_url(format)}|
    else
      %Q|constituency: #{name}\nmember_name: #{member_name}\nmember_party: #{member_party}\nmember_biography_url: #{member_biography_url}\nmember_website: #{member_website}\nuri: #{object_url(format)}|
    end
  end

  def to_csv
    headers = 'constituency_name,member_name,member_party,member_biography_url,member_website,uri'
    values = to_csv_value
    "#{headers}\n#{values}\n"
  end

  def to_csv_value
    if no_sitting_member?
      %Q|"#{name}","No sitting member","","","","#{object_url("csv")}"|
    else
      %Q|"#{name}","#{member_name}","#{member_party}","#{member_biography_url}","#{member_website}","#{object_url("csv")}"|
    end
  end

  def to_output_yaml
    "---\n#{to_text("yaml")}"
  end

  def member_name_changed? constituency
    member_name != constituency.member_name
  end

  def member_party_changed? constituency
    member_party != constituency.member_party
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

    def object_url format=nil
      url_for :host=>'localhost', :port=>'3000', :controller=>"constituencies", :action=>"show", :id => friendly_id, :format => format, :only_path => false
    end
end
