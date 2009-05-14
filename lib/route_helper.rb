require File.dirname(__FILE__) + '/../vendor/rails/actionpack/lib/action_controller/integration'

class RouteHelper

  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  def initialize app, helper, hostname
    app = ActionController::Integration::Session.new unless app
    @app = app
    @hostname = hostname
  end

  def method_missing symbol, *args
    if symbol.to_s.ends_with? 'url'
      @app.send(symbol, *args).sub('www.example.com', @hostname)
    end
  end

end
