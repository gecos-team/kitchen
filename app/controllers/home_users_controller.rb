class HomeUsersController < ApplicationController
  
  def index
    @users = HomeUser.all
  end     
  
  def edit 
    @user = HomeUser.find(params[:id])
  end  
  
  def update   
    @user = HomeUser.find(params[:id])    
    @databag = @user.databag  
    params[:databag][:id] = @databag.id
    Usermanagement.update(params[:databag])
    
    redirect_to edit_home_user_path(@user.username)
  end
  
end
