class Email < ActiveRecord::Base
  self.skip_time_zone_conversion_for_attributes = []

  def skip_time_zone_conversion_for_attributes
    []
  end

  def time_zone_aware_attributes
    false
  end
end
