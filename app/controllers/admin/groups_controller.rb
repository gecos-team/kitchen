class Admin::GroupsController < ApplicationController
  
  before_filter :require_admin
  
  def index  
    @groups = Group.all
  end   
  
  def new
    @group = Group.new
    @nodes = Node.all
  end   
  
  def create
    params[:group][:nodes_list] = params[:group][:nodes].reject {|key,value| value == "0" }.keys
    params[:group].delete(:nodes)
    @group = Group.create(params[:group])    
    redirect_to group_path(@group)
  end   
  
  def edit
    @group = Group.find(params[:id])
    @nodes = Node.all  
  end
  
  def update 
    @group = Group.find(params[:id])     
    params[:group][:nodes_list] = params[:group][:nodes].reject {|key,value| value == "0" }.keys 
    params[:group].delete(:nodes)
    @group.update_attributes(params[:group])    
    redirect_to group_path(@group)
  end
     
end
