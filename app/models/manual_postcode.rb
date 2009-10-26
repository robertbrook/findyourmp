class ManualPostcode < ActiveRecord::Base
  validates_uniqueness_of :code
  validates_presence_of :ons_id
  
  belongs_to :constituency
  
  delegate :name, :to => :constituency
  
  class << self
    def add_manual_postcode code, constituency_id, ons_id
      code.gsub!(' ', "")
      postcode = Postcode.find_by_code code
      unless postcode 
        unless ManualPostcode.find_by_code code
          manual_postcode = ManualPostcode.create  :code => code, :constituency_id => constituency_id, :ons_id => ons_id
          if manual_postcode
            postcode = Postcode.create :code => code, :constituency_id => constituency_id, :ons_id => ons_id
            unless postcode
              manual_postcode.delete
              return false
            end
          else
            return false
          end
        else
          Postcode.create :code => code, :constituency_id => constituency_id, :ons_id => ons_id
        end
      end
      true
    end
  end
  
  def remove
    postcode = Postcode.find_by_code code
    if postcode
      postcode.delete
    end
    self.delete
  end
end
