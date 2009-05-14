class SiteMap
  attr_reader :most_recent_modification, :location, :model, :empty, :site_map

  def route_helper
    @@route_helper ||= RouteHelper.new nil, nil, @hostname
  end

  def initialize hostname, logger=nil
    @logger = logger
    @hostname = hostname
  end

  def url_for url_helper_method, id_hash
    route_helper.send url_helper_method, id_hash
  end

  def entry
    new_entry location.sub('public/',''), most_recent_modification
  end

  # over ride in subclass
  def create_sitemap
    @site_map = ConstituencySiteMap.new(@hostname, @logger)
    @site_map.create_sitemap
  end

  def write_to_file!
    create_sitemap
    raise "can't write empty sitemap to file" if empty?
    raise "can only write to file once" unless site_map

    Zlib::GzipWriter.open(site_map.location) do |file|
      @logger.write 'writing: ' + site_map.location + "\n" if @logger
      file.write site_map.site_map
    end

    @site_map = nil
  end

  def empty?
    empty
  end

  def populate_sitemap name, pages
    unless (@empty = pages.empty?)
      site_map = [] <<
          %Q|<?xml version="1.0" encoding="UTF-8"?>\n| <<
          %Q|<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n|
      pages.each do |page|
        site_map <<
            '<url><loc>' << page.location << "</loc>" <<
            '<lastmod>' << page.last_modification.to_s << "</lastmod></url>\n" if page.location
      end
      site_map <<
          %Q|</urlset>\n|

      @most_recent_modification = pages.collect(&:last_modification).max
        @site_map = site_map.join('')
      @location = "public/sitemap.xml.gz"
    end
  end

  protected

    def new_entry location, last_modification=Date.today
      SiteMapEntry.new location, last_modification, @hostname
    end

end

class ModelSiteMap < SiteMap
  def create_sitemap
    populate_sitemap_for_model model, url_name
  end

  def url_name
    nil
  end

  def populate_sitemap_for_model model_class, url_helper_method=nil
    type = model_class.name.downcase
    url_helper_method = "#{type}_url".to_sym unless url_helper_method

    pages = [new_entry(type.pluralize)]
    resources = all_resources

    if !resources.empty? && resources.first.respond_to?(:friendly_id)
      resources = resources.sort_by(&:friendly_id)
      letters = resources.inject({}) {|hash,r| hash[r.friendly_id[0..0]]=true; hash }
      ('a'..'z').each do |letter|
        pages << new_entry("#{type.pluralize}/#{letter}") if letters[letter]
      end
    end

    pages += resources.collect do |resource|
      url = url_for(url_helper_method, resource)
      new_entry(url)
    end

    populate_sitemap type.pluralize, pages
  end

end

class ConstituencySiteMap < ModelSiteMap
  def all_resources
    all = model.find(:all)
    all.delete_if{|x| x.name == 'Example'}
    all
  end

  def model
    Constituency
  end

  def url_name
    :constituency_url
  end
end

class SiteMapEntry
  attr_accessor :location, :last_modification

  def initialize location, last_modification, hostname
    location = "http://#{hostname}/#{location}" unless location.starts_with?('http')
    @location, @last_modification = location, last_modification
  end
end


