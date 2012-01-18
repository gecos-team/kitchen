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

    if (!params[:node].blank? and !params[:node][:normal].blank?)
      @node.normal = @node.normal.merge(params[:node][:normal])
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
    unless (wizard = Cookbook.wizard_name(cookbook)).nil?
      return render :text => Wizard.text(wizard, @node, @skel, @defaults, @data)
    end
    respond_to do |format|
      format.html { render :layout => false}
      format.js { render :layout => false }
    end
  end

  def clean_data
    @node.clean_advanced_data(params[:recipe])
    render :nothing => true
  end


  protected

  def get_node
    @node = Node.find(params[:id])
  end

end
