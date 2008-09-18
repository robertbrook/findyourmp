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
end
