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
    if params[:role][:nodes] != nil
      params[:role][:node_list] = params[:role][:nodes].reject {|key,value| value == "0" }.keys
    else
      params[:role][:node_list] = []
    end
    params[:role].delete(:nodes)
    #HACK: Roles doesn't support spaces, so they are replaced by _
    params[:role][:name].gsub!(/ /,'_')
    @role = Role.new(params[:role])
    @role.assign_nodes(params[:role][:node_list])
    @role.update_attributes(params[:role])
    #@role.save
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
    params[:role][:name].gsub!(/ /,'_')
    @role.update_attributes(params[:role])
    redirect_to role_path(@role)
  end

  def destroy
    Role.delete(params[:id])
    redirect_to admin_root_path
  end
end
