class ConstituencySweeper < ActionController::Caching::Sweeper
  observe Constituency

  def after_save(consituency)
    expire_cache_for(consituency)
  end
    
  def after_destroy(consituency)
    expire_cache_for(consituency)
  end
    
  private
    def expire_cache_for(record)
      expire_page(:controller => 'consituency', :friendly_id => record.friendly_id, :action => 'show')
    end
end