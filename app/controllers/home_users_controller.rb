class HomeUsersController < ApplicationController
  
  def index
    @users = HomeUser.all
  end
  
end
