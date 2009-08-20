class BlacklistedPostcode < ActiveRecord::Base
  validates_uniqueness_of :code
  validates_presence_of :ons_id
end
