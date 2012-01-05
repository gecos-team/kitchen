class CookbooksController < ApplicationController

  def index
    @cookbooks = Cookbook.all
  end

  def check_recipe
    recipe = params[:recipe]
    render :json => Cookbook.is_advanced_recipe?(recipe)
  end


end
