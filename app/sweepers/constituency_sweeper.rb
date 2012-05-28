class ConstituencySweeper < ActionController::Caching::Sweeper
  observe Constituency

  def after_destroy(constituency)
    expire_cache_for(constituency)
  end

  def after_update(constituency)
    expire_cache_for(constituency)
  end

  def after_hide_members
    expire_constituency_cache
  end

  def after_unhide_members
    expire_constituency_cache
  end

  private
    def expire_cache_for(record)
      expire_page(:controller => 'constituencies', :action => 'show', :id => record.friendly_id)
      postcodes = record.postcode_districts.collect { |x| x.district }

      cache_dir = RAILS_ROOT+"/public/postcodes"
      postcodes.each do |cache_file|
        FileUtils.rm(Dir.glob("#{cache_dir}/#{cache_file}.html")) rescue Errno::ENOENT
      end
    end

    def expire_constituency_cache
      expire_page(:controller => 'constituencies', :action => 'show')
    end
end