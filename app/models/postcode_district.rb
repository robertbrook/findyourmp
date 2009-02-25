class PostcodeDistrict < ActiveRecord::Base
  belongs_to :constituency
  
  delegate :member_name, :to => :constituency
  delegate :member_website, :to => :constituency
  delegate :member_biography_link, :to => :constituency
  delegate :name, :to => :constituency
  
  class << self
    def find_all_by_district search_term
      return nil unless search_term
      district = String.new search_term
      district.strip!
      district.upcase!
      district.tr!(' ','')
      matches = find(:all, :conditions => %Q|district = "#{search_term}"|, :include => :constituency)
      
      if matches.empty?
        nil
      else
        matches
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