# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a3075db5ff3a469c66fda661be6d8070'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  before_filter :set_is_admin

  def is_admin?
    session[:is_admin]
  end

  def set_is_admin
    @is_admin = is_admin?
  end

  def toggle_admin
    if request.post?
      session[:is_admin] = !session[:is_admin]
    end
    redirect_to :back
  end

end
