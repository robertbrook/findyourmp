class Constituency < ActiveRecord::Base

  has_friendly_id :name, :use_slug => true, :strip_diacritics => true

  has_many :postcodes
  has_many :postcode_prefixes
  has_many :messages
  validate :valid_email?

  class << self
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


  def to_json
    if no_sitting_member?
      %Q|{"constituency": {"constituency_name": "#{name}", "ons_id": #{ons_id}, "member_name": "No sitting member", "member_party": "", "member_biography_url": "", "member_website": "" } }|
    else
      %Q|{"constituency": {"constituency_name": "#{name}", "ons_id": #{ons_id}, "member_name": "#{member_name}", "member_party": "#{member_party}", "member_biography_url": "#{member_biography_url}", "member_website": "#{member_website}" } }|
    end
  end

  def to_text
    if no_sitting_member?
      %Q|constituency: #{name}\nons_id: #{ons_id}\nmember_name: No sitting member\nmember_party: \nmember_biography_url: \nmember_website: |
    else
      %Q|constituency: #{name}\nons_id: #{ons_id}\nmember_name: #{member_name}\nmember_party: #{member_party}\nmember_biography_url: #{member_biography_url}\nmember_website: #{member_website}|
    end
  end

  def to_csv
    headers = 'constituency_name,ons_id,member_name,member_party,member_biography_url,member_website'
    values = to_csv_value
    "#{headers}\n#{values}\n"
  end
  
  def to_csv_value
    if no_sitting_member?
      %Q|"#{name}",#{ons_id},"No sitting member","","",""|
    else
      %Q|"#{name}",#{ons_id},"#{member_name}","#{member_party}","#{member_biography_url}","#{member_website}"|
    end
  end

  def to_output_yaml
    "---\n#{to_text}"
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
end
