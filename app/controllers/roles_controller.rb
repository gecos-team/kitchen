class RolesController < ApplicationController
  helper HomeUsersHelper
  before_filter :get_role, :except => "index"

  def index
    @roles = Role.all
  end

  def show
    @nodes = @role.nodes
    @roles = @role.available_roles
    @recipes = @role.available_recipes
  end

  def update
    if (!params[:role].blank? and !params[:role][:default_attributes].blank?)
      r_hash = HomeUsersHelper.recursive_hash(params[:role][:default_attributes].to_hash, {})
      @role.default_attributes = @role.default_attributes.merge(r_hash)
    elsif !params[:for_node].blank?
      @role.run_list = params[:for_node]
    end

    @role.save
    respond_to do |format|
      format.html {redirect_to role_path(@role.name)}
      format.js {}
    end

    #
    # @role.run_list = ["recipe[ohai]"] + params[:for_node]
    # @role.save
    # redirect_to role_path(@group)
  end


  def check_data
    recipe = params[:recipe]
    render :json => @role.advanced_data_empty_for?(recipe)
  end

  def advanced_data
    cookbook, recipe = params[:recipe].split("::")
    @skel = Cookbook.skel_for(cookbook, recipe)
    @defaults = Cookbook.initialize_attributes_for(cookbook, recipe)
    @data = @defaults.merge(@role.default_attributes)
    @use_default_data = @role.default_attributes["default"].blank? ? false : @role.default_attributes["default"][params[:recipe]] == "1"
    @input_class = "default"
    @input_class += " lock" if !@use_default_data.blank?
    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false }
    end
  end

  def clean_data
    @role.clean_advanced_data(params[:recipe])
    render :nothing => true
  end


  protected

  def get_role
    @role = Role.find(params[:id])
  end


end
