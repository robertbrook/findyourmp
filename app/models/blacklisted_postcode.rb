class BlacklistedPostcode < ActiveRecord::Base
  
  validates_uniqueness_of :code
  validates_presence_of :ons_id
  
  def initialize new_code=nil, new_constituency_id=nil, new_ons_id=nil
    super(nil)
    self.code = new_code
    self.constituency_id = new_constituency_id
    self.ons_id = new_ons_id
  end
end
