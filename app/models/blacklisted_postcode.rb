class BlacklistedPostcode < ActiveRecord::Base
  validates_uniqueness_of :code
  validates_presence_of :ons_id
  
  belongs_to :constituency
  
  delegate :name, :to => :constituency
  
  def restore
    postcode = Postcode.find_by_code code
    unless postcode
      postcode = Postcode.create(:code => code, :constituency_id => constituency_id, :ons_id => ons_id)
    end
    self.delete if postcode
  end
end