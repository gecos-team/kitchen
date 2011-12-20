class HomeUsersController < ApplicationController
  
  def index
    @users = HomeUser.all
  end     
  
  def edit 
    @user = HomeUser.find(params[:id])
  end  
  
  def update   
    @user = HomeUser.find(params[:id])   
    debugger
  end
  
end
