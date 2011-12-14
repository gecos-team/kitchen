class SearchController < ApplicationController    
  
  def show 
    @nodes = Node.search("name:*#{params[:id]}*")
  end
  
  def index
    @search = params[:id]
    redirect_to search_path(@search)
  end
  
end
