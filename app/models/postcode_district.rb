class PostcodeDistrict < ActiveRecord::Base
  belongs_to :constituency

  delegate :member_name, :to => :constituency
  delegate :member_website, :to => :constituency
  delegate :member_biography_link, :to => :constituency
  delegate :name, :to => :constituency
  delegate :friendly_id, :to => :constituency

  class << self
    def find_all_by_district search_term
      if search_term && search_term.size < 5
        code = String.new search_term
        code.strip!
        code.upcase!
        code.tr!('"','')
        code.tr!(' ','')
        results = find(:all, :conditions => %Q|district = "#{code}"|, :include => :constituency)
        if results.empty? && code.length() == 3
          results = find(:all, :conditions => %Q|district LIKE "#{code}%"|, :group => :constituency_id, :include => :constituency)
        end
        results
      else
        []
      end
    end
  end

  def constituency_name
    if constituency
      constituency.name
    end
  end
end