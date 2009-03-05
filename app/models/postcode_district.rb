class PostcodeDistrict < ActiveRecord::Base
  belongs_to :constituency

  delegate :member_name, :to => :constituency
  delegate :member_website, :to => :constituency
  delegate :member_biography_link, :to => :constituency
  delegate :name, :to => :constituency

  class << self
    def find_all_by_district search_term
      if search_term && search_term.size < 5
        code = String.new search_term
        code.strip!
        code.upcase!
        code.tr!(' ','')
        find(:all, :conditions => %Q|district = "#{code}"|, :include => :constituency)
      else
        []
      end
    end
  end

  def id
    if constituency
      constituency.friendly_id
    end
  end

  def constituency_name
    if constituency
      constituency.name
    end
  end
end