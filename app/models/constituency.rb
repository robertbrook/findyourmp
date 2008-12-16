class Constituency < ActiveRecord::Base

  has_many :postcodes
  has_many :messages

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

  def code
    if id < 10
      "00#{id}"
    elsif id < 100
      "0#{id}"
    else
      id.to_s
    end
  end

  def no_sitting_member?
    member_name.blank? || !member_visible
  end
end
