class GroupsController < ApplicationController  
  
  def index 
    @groups = Group.all  
  end
  
  def show               
    @group = Group.find(params[:id])
    @nodes = @group.nodes
    @roles = @group.avaiable_roles
    @recipes = @group.avaiable_recipes
    
  end     
  
  def update
    @group = Group.find(params[:id]) 
    @group.nodes.each do |node|   
      node.run_list = (["recipe[ohai]"] + [node.run_list] + [params[:for_node]]).flatten.uniq      
      node.save
    end
    redirect_to group_path(@group)
  end
  
end
