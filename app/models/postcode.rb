class Postcode < ActiveRecord::Base

  belongs_to :constituency

  delegate :member_name, :to => :constituency

  class << self
    def find_postcode_by_code search_term
      code = String.new search_term
      code.strip!
      code.upcase!
      code.tr!(' ','')
      find_by_code(code, :include => :constituency)
    end
  end

  def constituency_name
    if constituency
      constituency.name
    else
      raise "constituency not found for constituency_id: #{constituency_id}, postcode: #{code}"
    end
  end

  def code_prefix
    code[0..-4]
  end

  def code_with_space
    suffix = code[-3,3]
    "#{code_prefix} #{suffix}"
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

  def to_output_yaml
    "---\n#{to_text}"
  end
end
