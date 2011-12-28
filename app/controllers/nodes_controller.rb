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
    if !params[:for_node].blank?
      @node.run_list = (["recipe[ohai]"] + [params[:for_node]]).flatten.uniq.compact
    elsif !params[:node][:normal].blank?
      @node.normal = @node.normal.merge(params[:node][:normal])
    end

    @node.save
    redirect_to node_path(@node.name)
  end


  def check_recipe
    recipe = params[:recipe]
    render :json => Cookbook.is_advanced_recipe?(recipe)
  end

  def advanced_data
    cookbook, recipe = params[:recipe].split("::")
    @skel = Cookbook.skel_for(cookbook)
    @data = Cookbook.initialize_attributes_for(recipe).merge(@node.normal)

  end


  protected

  def get_node
    @node = Node.find(params[:id])
  end

end
