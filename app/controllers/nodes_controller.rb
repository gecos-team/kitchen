class NodesController < ApplicationController

  helper HomeUsersHelper
  before_filter :get_node, :except => "index"

  def index
    if params[:name]
      @nodes = Node.search("name:*#{params[:name]}*")
    else
      @nodes = Node.all
    end
  end

  def show
    @roles = @node.available_roles
    @recipes = @node.available_recipes

    respond_to do |format|
      format.html
      format.json { render :json => @node.to_json }
    end
  end

  def edit
  end

  def update
    if (!params[:node].blank? and !params[:node][:normal].blank?)
      r_hash = HomeUsersHelper.recursive_hash(params[:node][:normal].to_hash, {})
      @node.normal = @node.normal.merge(r_hash)
    elsif !params[:for_node].blank?
      @node.run_list = params[:for_node]
    end

    @node.save
    respond_to do |format|
      format.html {redirect_to node_path(@node.name)}
      format.js {}
    end
  end



  def check_data
    recipe = params[:recipe]
    render :json => @node.advanced_data_empty_for?(recipe)
  end

  def advanced_data
    cookbook, recipe = params[:recipe].split("::")
    @skel = Cookbook.skel_for(cookbook, recipe)
    @defaults = Cookbook.initialize_attributes_for(cookbook, recipe)
    @data = @defaults.merge(@node.normal)
    @use_default_data = @node.normal["default"].blank? ? false : @node.normal["default"][params[:recipe]] == "1"
    @input_class = "default"
    @input_class += " lock" if !@use_default_data.blank?
    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false }
    end
  end

  def clean_data
    @node.clean_advanced_data(params[:recipe])
    render :nothing => true
  end

  def search_packages
    render :json => @node.search_package(params[:q])
  end




  protected

  def get_node
    @node = Node.find(params[:id])
  end

end
