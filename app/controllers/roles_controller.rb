class RolesController < ApplicationController

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
      @role.default_attributes = @role.default_attributes.merge(params[:role][:default_attributes])
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
    @data = @defaults.merge(@role.normal)
    @use_default_data = @role.normal["default"].blank? ? false : @role.normal["default"][params[:recipe]] == "1"
    @input_class = "default"
    @input_class += " lock" if !@use_default_data.blank?
    # unless (wizard = Cookbook.wizard_name(cookbook)).nil?
    #   return render :text => Wizard.text(wizard, @node, @skel, @defaults, @data)
    # end
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
