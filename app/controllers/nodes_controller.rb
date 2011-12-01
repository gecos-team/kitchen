class NodesController < ApplicationController  
  
  def index    
    if params[:name]
      @nodes = Node.search("name:*#{params[:name]}*")
    else
      @nodes = Node.all
    end
  end  
  
  def show
    @node = Node.find(params[:id])
    @roles = @node.avaiable_roles
    @recipes = @node.avaiable_recipes
  end
                
  def edit  
     @node = Node.find(params[:id]) 
  end 
  
end
