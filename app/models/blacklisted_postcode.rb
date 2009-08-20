class BlacklistedPostcode < ActiveRecord::Base
  
  validates_uniqueness_of :code
  validates_presence_of :ons_id
  
  class << self
    def find_postcode_by_code search_term
      return nil unless search_term
      code = String.new search_term
      code.strip!
      code.upcase!
      code.tr!(' ','')
      find_by_code(code, :include => :constituency)
    end
  end
  
  def initialize new_code=nil, new_constituency_id=nil, new_ons_id=nil
    super(nil)
    self.code = new_code
    self.constituency_id = new_constituency_id
    self.ons_id = new_ons_id
  end
end
