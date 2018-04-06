class Admin::UsersController < ApplicationController
  # before_action :require_developer

  def create
  end

  def index
    @users = User.all
  end

  def show

  end

  def update

  end

  def destroy

  end

end
