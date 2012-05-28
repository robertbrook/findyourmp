class UsersController < ApplicationController

  layout 'application'

  before_filter :require_user
  before_filter :require_admin_user, :except => [:edit, :update]
  before_filter :set_user, :only => [:edit, :update]

  def new
    @user = User.new
  end

  def index
    @users = User.all
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default users_path
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
  end

  def update
    if @own_account
      @user.email = params[:user][:email]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      save_user
    else
      @user.email = params[:user][:email]
      @user.admin = params[:user][:admin]
      save_user
    end
  end

  def destroy
    # todo
  end

  private

    def save_user
      if @user.save
        flash[:notice] = "Account updated!"
        redirect_to edit_user_path(@user)
      else
        render :action => :edit
      end
    end

    def set_user
      user_id = params[:id]
      if current_user.id == user_id.to_i
        @user = current_user
        @own_account = true
      elsif current_user.admin?
        @user = User.find(user_id)
        @own_account = false
      else
        flash[:notice] = "You must be logged in as an admin user to access this page"
        redirect_to admin_path
      end
    end
end
