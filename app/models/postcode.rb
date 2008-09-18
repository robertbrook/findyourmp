class Postcode < ActiveRecord::Base

  belongs_to :constituency

  delegate :member_name, :to => :constituency

  def constituency_name
    constituency.name
  end

end
