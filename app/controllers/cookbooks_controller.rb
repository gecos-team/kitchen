class CookbooksController < ApplicationController
  
  def index
    @cookbooks = Cookbook.all
  end
  
end
