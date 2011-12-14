class Admin::HomeController < ApplicationController      
  
  before_filter :require_admin
  
  def index
  end
  
end
