# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a3075db5ff3a469c66fda661be6d8070'

  filter_parameter_logging :password, :password_confirmation

  helper_method :current_user_session, :is_admin?

  def render_not_found message='Page not found.'
    render :text => message, :status => :not_found
  end

  private
    def render_unauthorized
      render :text => 'Unauthorized', :status => 401
    end

    def respond_unauthorized_if_not_admin
      render_unauthorized unless is_admin?
    end

    def is_admin?
      current_user ? true : false
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
