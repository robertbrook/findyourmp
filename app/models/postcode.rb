class Postcode < ActiveRecord::Base
  include ActionController::UrlWriter

  before_validation_on_create :populate_constituency_id

  validates_uniqueness_of :code
  validates_presence_of :ons_id

  belongs_to :constituency

  delegate :member_name, :to => :constituency

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

  def in_constituency? constituency
    self.constituency_id == constituency.id
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

  def to_json host, port
    member = member_name ? %Q|, "member_name": "#{member_name.strip}"| : ''
    %Q|{"postcode": {"code": "#{code_with_space}", "constituency_name": "#{constituency_name}"#{member}, "uri": "#{object_url(host, port, "json")}"} }|
  end

  def to_text host, port, format="txt"
    member = member_name ? %Q|\nmember_name: #{member_name.strip}| : ''
    %Q|postcode: #{code_with_space}\nconstituency_name: #{constituency_name}#{member}\nuri: #{object_url(host, port, format)}\n|
  end

  def to_csv host, port
    headers = 'postcode,constituency_name'
    values = %Q|"#{code_with_space}","#{constituency_name}"|
    if member_name
      headers += ',member_name'
      values += %Q|,"#{member_name.strip}"|
    end
    headers += ",uri"
    values += %Q|,"#{object_url(host, port, "csv")}"|
    "#{headers}\n#{values}\n"
  end

  def to_output_yaml host, port
    "---\n#{to_text(host, port, "yaml")}"
  end

  def blacklist
    blacklisted = BlacklistedPostcode.find_by_code(code)
    unless blacklisted
      blacklisted = BlacklistedPostcode.create :code => code, :constituency_id => constituency_id ,:ons_id => ons_id
      if blacklisted
        self.delete
      else
        return false
      end
    else
      self.delete
    end
    true
  end

  private

    def populate_constituency_id
      if ons_id
        if constituency = Constituency.find_by_ons_id(ons_id)
          self.constituency_id = constituency.id
        # else
          # errors.add('constituency_id', "Can't find a constituency corresponding to ONS ID: #{ons_id}")
        end
      end
    end

    def object_url host, port, format=nil
      if port.to_s == "80"
        url_for :host=> host, :controller=>"postcodes", :action=>"show", :postcode => code, :format => format, :only_path => false
      else
        url_for :host=> host, :port=> port, :controller=>"postcodes", :action=>"show", :postcode => code, :format => format, :only_path => false
      end
    end
end
