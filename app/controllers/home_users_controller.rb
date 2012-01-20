class HomeUsersController < ApplicationController

  def index
    @users = HomeUser.all
  end

  def edit
    @user = HomeUser.find(params[:id])
    @user.databag = Usermanagement.find("user_skel") if @user.databag.blank?
  end

  def update

    @databag = Usermanagement.find_or_create(params[:id])
    @user = HomeUser.find(params[:id])

    #Insert id into json to load
    params[:databag][:id] = @databag.id
    params[:databag][:username] = @databag.username

    #Ugly fix for multiple attributes. While form needs unique ids in inputs, json not. Try to parse it to get something similar to no-unique form ids.
    @user.multiple_in_skel.each do |multiple|
      attribute = params[:databag][multiple].keys.first
      params[:databag][multiple][attribute] = params[:databag][multiple].values.map{|x| x.values}.flatten
    end

    Usermanagement.update(params[:databag])

    redirect_to edit_home_user_path(@user.username)
  end

end
