class Postcode < ActiveRecord::Base

  belongs_to :constituency

  delegate :member_name, :to => :constituency

  def constituency_name
    constituency.name
  end

  def code_with_space
    suffix = code[-3,3]
    prefix = code[0..-4]
    "#{prefix} #{suffix}"
  end

  def to_json
    member = member_name ? %Q|, "member_name": "#{member_name.strip}"| : ''
    %Q|{"postcode": {"code": "#{code_with_space}", "constituency_id": #{constituency_id}, "constituency_name": "#{constituency_name}"#{member}}|
  end
end
