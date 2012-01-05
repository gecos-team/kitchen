class Admin::RolesController < ApplicationController
  before_filter :require_admin

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
    @nodes = Node.all
  end

  def create
    params[:role][:node_list] = params[:role][:nodes].reject {|key,value| value == "0" }.keys
    params[:role].delete(:nodes)
    @role = Role.new(params[:role])
    @role.assign_nodes(params[:role][:node_list])
    @role.save
    # @role.assign_nodes(params[:role][:node_list])
    #
    # @role.save
    redirect_to role_path(@role.name)
  end

  def edit
    @role = Role.find(params[:id])
    @nodes = Node.all
  end

  def update
    @role = Role.find(params[:id])
    params[:role][:node_list] = params[:role][:nodes].reject {|key,value| value == "0" }.keys
    @role.update_attributes(params[:role])
    redirect_to role_path(@role)
  end

  def destroy
    Role.delete(params[:id])
    redirect_to admin_root_path
  end
end
