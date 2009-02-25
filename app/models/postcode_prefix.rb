class PostcodePrefix < ActiveRecord::Base
  belongs_to :constituency
  
  delegate :member_name, :to => :constituency
  delegate :member_website, :to => :constituency
  delegate :member_biography_link, :to => :constituency
  delegate :name, :to => :constituency
  
  class << self
    def find_all_by_prefix search_term
      return nil unless search_term
      prefix = String.new search_term
      prefix.strip!
      prefix.upcase!
      prefix.tr!(' ','')
      matches = find(:all, :conditions => %Q|prefix = "#{search_term}"|, :include => :constituency)
      
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