class UserSessionsController < ApplicationController
  
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = ''
      redirect_back_or_default admin_url
    else
      flash[:notice] = 'Your user name and password combination was not recognized. Please try again.'
      sleep 2 unless ENV["RAILS_ENV"] == 'test'
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    redirect_back_or_default root_url
  end
end
