require 'yaml'
require 'hpricot'
require 'net/http'
require 'open-uri'
require 'uri'
# require 'morph'

class UpMyStreet
  @@step_off = 1

  class << self
    def load_upmystreet_codes file
      doc = Hpricot open(file)

      get_start_nodes(doc).each do |node|
        code_data = load_code node
        #puts code_data.to_yaml

        upmystreetcode = UpMyStreetCode.find_by_code(code_data.code)
        unless upmystreetcode
          upmystreetcode = UpMyStreetCode.new()
          upmystreetcode.code = code_data.code
        end
        constituency = Constituency.find_by_constituency_name(code_data.constituency)

        upmystreetcode.constituency = constituency.friendly_id
        upmystreetcode.save!
      end
    end

    def is_hpricot_node
      uri.respond_to?(:to_str)
    end

    def fetch(uri)
      begin
        uri = URI.parse(uri) if is_hpricot_node(uri)
        Net::HTTP.start(uri.host, uri.port) do |http|
          return http.get(uri.path+'?'+uri.query, 'Referer'=> 'http://www.parliament.uk/directories/hciolists/alms.cfm')
        end
      rescue
        @@step_off += 1
        sleep 2 * @@step_off
        fetch uri
      end
    end

    def load_upmystreet_code
      UpMyStreetCode.load_codes 'http://www.parliament.uk/directories/hciolists/alms.cfm'
    end

    def get_start_nodes doc
      start_nodes = (doc/'tr').select do |tr|
        is_row = (tr['bgcolor'] == '#f1ece4' || tr['valign'] == 'TOP')
        contains_table_cells = !tr.next_node.to_s.strip.empty? && tr.next_node.name == 'td'
        is_row && contains_table_cells
      end
    end

    def load_code node
      UpMyStreetData.new(node)
    end
  end
end

class UpMyStreetData < UpMyStreet
  attr_accessor :constituency, :code

  def initialize node
    set_constituency   node.next_node
    set_code           node.next_node.next_node
  end

  protected

    def set_constituency(node)
      parts = node.to_s.gsub('</td>','').split('<td>').delete_if{|t| t.blank?}
      self.constituency = parts[1] if parts.size > 0
    end

    def set_code(node)
      url = node.at('a')['href']
      contact_url = url unless url == 'noemail.cfm'

      code = nil
      unless contact_url.nil?
        if contact_url[/email\/l\/(\d+).html$/]
          code = $1
        end
      end

      self.code = code unless code.nil?
    end
end
