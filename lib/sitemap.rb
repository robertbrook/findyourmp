class SiteMap
  include Rails.application.routes.url_helpers
  attr_reader :most_recent_modification, :location, :model, :empty, :site_map
  
  
  def initialize hostname, logger=nil
    @logger = logger
    @hostname = hostname
  end

  def entry
    new_entry location.sub('public/',''), most_recent_modification
  end

  # over ride in subclass
  def create_sitemap
    if (ENV["RAILS_ENV"] != 'test') && File.exists?("public/sitemap.xml.gz")
      site_map_time = File.new("public/sitemap.xml.gz").mtime
      last_update_time = Constituency.all.collect(&:updated_at).max
      needs_update = last_update_time > site_map_time
      if needs_update
        @site_map = ConstituencySiteMap.new(@hostname, @logger)
        @site_map.create_sitemap
      else
        @site_map = nil
      end
    else
      @site_map = ConstituencySiteMap.new(@hostname, @logger)
      @site_map.create_sitemap
    end
  end
  
  def write_to_file!
    create_sitemap
    if site_map
      raise "can't write empty sitemap to file" if empty?
      raise "can only write to file once" unless site_map
      
      Zlib::GzipWriter.open(site_map.location) do |file|
        @logger.write 'writing: ' + site_map.location + "\n" if @logger
        file.write site_map.site_map
      end
      
      @site_map = nil
    end
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
        if page.last_modification.is_a?(Time)
          last_modification = page.last_modification.to_date.to_s(:utc)
        else
          last_modification = page.last_modification
        end
        site_map <<
            '<url><loc>' << page.location << "</loc>" <<
            '<lastmod>' << last_modification.to_s << "</lastmod></url>\n" if page.location
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
    pages = [new_entry('')]    
    populate_sitemap_for_model pages, model
  end
  
  def populate_sitemap_for_model pages, model_class
    type = model_class.name.downcase    
    resources = all_resources
    
    pages += resources.collect do |resource|
      resource_id = resource.respond_to?(:slug) ? resource.slug : resource.id
      url = url_for({:controller => type.pluralize, :action => "show", :id => resource_id, :host => @hostname})
      new_entry(url, resource.updated_at)
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
end

class SiteMapEntry
  attr_accessor :location, :last_modification

  def initialize location, last_modification, hostname
    location = "http://#{hostname}/#{location}" unless location.starts_with?('http')
    @location, @last_modification = location, last_modification
  end
end