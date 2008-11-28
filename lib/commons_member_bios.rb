class CommonsMemberBios < MemberBios

  include Morph

  class << self

    def get_start_nodes doc
      start_nodes = (doc/'tr').select do |tr|
        is_row = (tr['bgcolor'] == '#f1ece4' || tr['valign'] == 'TOP')
        contains_table_cells = !tr.next_node.to_s.strip.empty? && tr.next_node.name == 'td'
        is_row && contains_table_cells
      end
    end

    def load_bio node
      CommonsMemberBios.new(node)
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
      dods_url = node.at('a')['href']
      # self.bio_url = self.class.fetch(dods_url)['location']
      self.bio_url = dods_url
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
