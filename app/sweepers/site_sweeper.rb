class SiteSweeper < ActionController::Caching::Sweeper
  observe Constituency, Postcode
  
  def after_save(site)
    self.class::sweep
  end
  
  def after_destroy(site)
    self.class::sweep
  end
  
  def self.sweep
    cache_dirs = [ RAILS_ROOT+"/public/constituencies", RAILS_ROOT+"/public/postcodes", RAILS_ROOT+"/public/search" ]
    cache_dirs.each do |cache_dir|
      FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
      RAILS_DEFAULT_LOGGER.info("Cache directory '#{cache_dir}' fully swept.")
    end
  end
end