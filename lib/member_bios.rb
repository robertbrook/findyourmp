require 'yaml'
require 'hpricot'
require 'net/http'
require 'open-uri'
require 'uri'
require 'morph'

class MemberBios

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
