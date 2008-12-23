require 'yaml'
require 'hpricot'
require 'net/http'
require 'open-uri'
require 'uri'
require 'morph'

class MemberBiography
  @@step_off = 1

  class << self
    def load_bios file
      doc = Hpricot open(file)

      get_start_nodes(doc).each do |node|
        bio = load_bio node
        # puts bio.to_yaml

        constituency = Constituency.find_by_constituency_name(bio.constituency)
        if constituency
          print '.'
          $stdout.flush
          constituency.member_website = bio.member_website
          constituency.member_biography_url = bio.bio_url
          constituency.save!
        else
          raise "constituency not found: " + bio.constituency
        end
      end
      puts ''
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
  end
end

class CommonsMemberBiography < MemberBiography

  include Morph

  class << self

    def load_biographies
      CommonsMemberBiography.load_bios 'http://www.parliament.uk/directories/hciolists/alms.cfm'
    end

    def get_start_nodes doc
      start_nodes = (doc/'tr').select do |tr|
        is_row = (tr['bgcolor'] == '#f1ece4' || tr['valign'] == 'TOP')
        contains_table_cells = !tr.next_node.to_s.strip.empty? && tr.next_node.name == 'td'
        is_row && contains_table_cells
      end
    end

    def load_bio node
      CommonsMemberBiography.new(node)
    end
  end

  def initialize node
    set_name           node.next_node
    set_contact_url    node.next_node.next_node
    set_member_website node.next_node.next_node.next_node
    set_bio_url        node.next_node.next_node.next_node.next_node
  end

  protected

    def set_name(node)
      parts = node.to_s.gsub('</td>','').split('<td>').delete_if{|t| t.blank?}
      name = parts.first

      self.name_end = find_name_end(name)
      self.name_start = find_name_start(name)
      self.party_or_affiliation = find_party(name)
      self.constituency = parts[1] if parts.size > 0
    end

    def set_contact_url(node)
      url = node.at('a')['href']
      self.contact_url = url unless url == 'noemail.cfm'
    end

    def set_member_website(node)
      self.member_website = node.at('a')['href'] if node.at('a')
    end

    def set_bio_url(node)
      dods_url = node.at('a')['href'].to_s
      if dods_url[/id=(\d+)$/]
        self.bio_url = "http://biographies.parliament.uk/parliament/default.asp?id=#{$1}"
      else
        self.bio_url = dods_url
      end
    end

    def find_name_end text
      return name_parts(text)[0]
    end

    def find_name_start text
      return name_parts(text)[1]
    end

    def find_party text
      return name_parts(text)[2]
    end

    def name_parts text
      text[/^([^,]+), ([^(]+) \(([^)]+)\)$/]
      return $1,$2,$3
    end
end
