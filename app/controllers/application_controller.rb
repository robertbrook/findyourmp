# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging :password, :password_confirmation, :message, :constituency_list
  # filter_parameter_logging :password, :user

  helper_method :current_user_session, :is_admin?

  def render_not_found message='Page not found.'
    #render :text => message, :status => :not_found
    @title = "Page cannot be found (404 error)"
    @crumbtrail = "Error page cannot be found"
    render :template => 'public/404.html', :status => 404
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

    def require_admin_user
      require_user
      unless current_user.admin?
        redirect_to admin_path
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        redirect_to admin_path
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

     def results_to_json constituencies, members
        constituencies_json = ""
        constituencies.each do |constituency|
          constituencies_json += ", " unless constituencies_json == ""
          constituencies_json += constituency.to_json[1..-2]
        end

        members_json = ""
        members.each do |member|
          members_json += ", " unless members_json == ""
          members_json += member.to_json[1..-2]
        end

        constituencies_results = %Q|"constituencies": {#{constituencies_json}}|
        members_results = %Q|"members": {#{members_json}}|

        %Q|{"results": { #{constituencies_results}, #{members_results} }} |
      end

      def results_to_text constituencies, members
        results = ""
        constituencies.each do |constituency|
          results += "\n\n"
          results += "  - " + constituency.to_text.gsub("\n", "\n\    ")
        end
        members.each do |member|
          results += "\n\n"
          results += "  - " + member.to_text.gsub("\n", "\n    ")
        end
        "constituencies:" + results
      end

      def results_to_yaml constituencies, members
        "---\n#{results_to_text(constituencies, members)}"
      end

    def results_to_csv constituencies, members
      headers = 'constituency_name,member_name,member_party,member_biography_url,member_website'
      values = ""

      constituencies.each do |constituency|
        values += constituency.to_csv_value + "\n"
      end

      members.each do |constituency|
        values += constituency.to_csv_value + "\n"
      end

      "#{headers}\n#{values}\n"
    end

    def message_to_json root, message
      %Q|{"#{root}": "#{message}"}|
    end

    def message_to_text root, message
      %Q|#{root}: #{message}\n|
    end

    def message_to_csv root, message, root_header, message_header
      headers = %Q|"#{root_header}","#{message_header}"|
      values = %Q|"#{root}","#{message}"|
      "#{headers}\n#{values}\n"
    end

    def message_to_yaml root, message
      "---\n#{message_to_text(root, message)}"
    end

end
