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

  def to_text
    member = member_name ? %Q|\nmember_name: #{member_name.strip}| : ''
    %Q|postcode: #{code_with_space}\nconstituency_id: #{constituency_id}\nconstituency_name: #{constituency_name}#{member}\n|
  end

  def to_csv
    headers = 'postcode,constituency_id,constituency_name'
    values = %Q|"#{code_with_space}",#{constituency_id},"#{constituency_name}"|
    if member_name
      headers += ',member_name'
      values += %Q|,"#{member_name.strip}"|
    end
    "#{headers}\n#{values}\n"
  end

end
