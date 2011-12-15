class NodesController < ApplicationController  
  
  before_filter :get_node, :except => "index"
  
  def index    
    if params[:name]
      @nodes = Node.search("name:*#{params[:name]}*")
    else
      @nodes = Node.all
    end
  end  
  
  def show
    @roles = @node.avaiable_roles
    @recipes = @node.avaiable_recipes 
    
    respond_to do |format|
      format.html
      format.json { render :json => @node.to_json }
    end
  end
                
  def edit  
  end       
  
  def update       
    # debugger
    @node.run_list = (["recipe[ohai]"] + [params[:for_node]]).flatten.uniq.compact      
    @node.save
    redirect_to node_path(@node.name)
  end   
  
  
  
  protected
  
  def get_node
    @node = Node.find(params[:id])  
  end
  
end
