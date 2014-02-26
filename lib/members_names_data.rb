#encoding: utf-8

require 'rest-client'
require 'nokogiri'

class MembersNamesData
  def initialize(url=nil)
    unless url
      url = "http://data.parliament.uk/membersdataplatform/services/mnis/members/query/House=Commons/Addresses"
    end
    @data = fetch(url)
  end
  
  def to_tsv
    doc = Nokogiri::XML(@data)
    members = doc.search("//Member")
    rows = []
    members.each do |member|
      row = []
      row << "\"#{member.at("MemberFrom/text()").to_s.gsub("&#xF4;", "o")}\""
      row << "\"#{member.at("DisplayAs/text()").to_s}\""
      row << "\"#{member.at("Party/text()").to_s}\""
      row << "\"#{"http://www.parliament.uk/biographies/commons/#{member.at("DisplayAs/text()").to_s.gsub(" ", "-")}/#{member.attribute("Member_Id")}"}\""
      row << "\"#{member.at("Addresses/Address[@Type_Id='1']/Email/text()").to_s.gsub("mailto:", "").gsub(/;.*/, "")}\""
      row << "\"#{member.at("Addresses/Address[@Type_Id='6']/Address1/text()").to_s}\""
      row << "\"#{member.at("CurrentStatus").attr("IsActive")}\""
      rows << row.join("\t")
    end
    rows.sort.join("\n")
  end
  
  
  private
  
  def fetch(data_url)
    response = RestClient.get(data_url)
    response.body
  end
end