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
  end
                
  def edit  
     @node = Node.find(params[:id]) 
  end 
  
end
