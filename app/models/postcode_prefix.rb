class PostcodePrefix < ActiveRecord::Base
  belongs_to :constituency
  
  delegate :member_name, :to => :constituency
  delegate :ons_id, :to => :constituency
  delegate :name, :to => :constituency
  
  class << self
    def find_all_by_prefix search_term
      return nil unless search_term
      prefix = String.new search_term
      prefix.strip!
      prefix.upcase!
      prefix.tr!(' ','')
      find(:all, :conditions => %Q|prefix = "#{search_term}"|, :include => :constituency)
    end
  end
  
  def constituency_name
    if constituency
      constituency.name
    else
      raise "constituency not found for constituency_id: #{constituency_id}, postcode_prefix: #{prefix}"
    end
  end
end