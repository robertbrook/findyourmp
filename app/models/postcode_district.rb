class PostcodeDistrict < ActiveRecord::Base
  belongs_to :constituency
  
  delegate :member_name, :to => :constituency
  delegate :member_website, :to => :constituency
  delegate :member_biography_link, :to => :constituency
  delegate :name, :to => :constituency
  
  class << self
    def find_all_by_district search_term
      return nil unless search_term
      code = String.new search_term
      code.strip!
      code.upcase!
      code.tr!(' ','')
      find(:all, :conditions => %Q|district = "#{code}"|, :include => :constituency)
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