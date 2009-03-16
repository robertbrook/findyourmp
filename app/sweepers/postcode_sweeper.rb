class PostcodeSweeper < ActionController::Caching::Sweeper
  observe Postcode

  def after_save(postcode)
    expire_cache_for(postcode)
  end
    
  def after_destroy(postcode)
    expire_cache_for(postcode)
  end
    
  private
    def expire_cache_for(record)
      expire_page(:controller => 'postcode', :code => record.code, :action => 'show')
    end
end