class Admin::PrintersController < ApplicationController
  before_filter :require_admin

  def index
    databag = Databag.find("available_printers")
    @printers = databag.empty? ? {} : databag.value
  end

  def new
    @printer = Printer.new
    databag = Databag.find("printers")
    @makes = databag.empty? ? [] : databag.value.keys.sort
  end

  def create
    @printer = Printer.new(params[:printer].except(:ppd, :ppd_file))
    make = params[:printer][:make]
    model = params[:printer][:model]
    if @printer.valid?
      if params[:printer][:ppd_file].present?
        basename = PPDUpload.save(params[:printer][:host],params[:printer][:ppd_file], make)
        @printer.ppd = basename
        @printer.ppd_uri = PPDUpload.ppd_uri(params[:printer][:host],basename, make)
        @printer.create!
      else
        printer = Databag.find("printers/#{make}").value[model]
        if printer["recommended_ppd"].present?
          @printer.ppd = printer["recommended_ppd"]
          @printer.ppd_uri = PPDUpload.ppd_uri(params[:printer][:host],@printer.ppd, make)
        end
        @printer.create!
      end
      redirect_to admin_printers_path
    else
      # Do not enclose fields with errors in a div.field_with_errors
      # see http://guides.rubyonrails.org/active_record_validations_callbacks.html#customizing-the-error-messages-html
      ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
        html_tag
      end
      databag = Databag.find("printers")
      @makes = databag.empty? ? [] : databag.value.keys.sort
      if (make = params[:printer][:make]).present?
        if (model = params[:printer][:model]).present?
          databag = Databag.find("printers/#{make}")
          @models = databag.empty? ? [] : databag.value.keys.reject{ |k| k == "id" }.sort
        end
      end
      render :action => :new
    end
  end

  def edit
    databag = Databag.find("available_printers/#{params[:id]}")
    @printer = Printer.instantiate(databag.empty? ? {} : databag.value)
    databag = Databag.find("printers")
    @makes = databag.empty? ? [] : databag.value.keys.sort
    databag = Databag.find("printers/#{@printer.make}")
    @models = databag.empty? ? [] : databag.value.keys.reject{ |k| k == "id" }.sort
  end

  def update
    databag = Databag.find("available_printers/#{params[:id]}")
    @printer = Printer.instantiate(databag.empty? ? {} : databag.value)
    @printer.update_attributes(params[:printer])
    if @printer.valid?
      if params[:printer][:ppd_file].present?
        make = params[:printer][:make]
        model = params[:printer][:model]
        basename = PPDUpload.save(params[:printer][:host],params[:printer][:ppd_file], make)
        @printer.ppd = basename
        @printer.ppd_uri = PPDUpload.ppd_uri(params[:printer][:host],basename, make)
      else
        printer = Databag.find("printers/#{params[:printer][:make]}").value[params[:printer][:model]]
        if printer["recommended_ppd"].present?
          @printer.ppd = printer["recommended_ppd"]
          @printer.ppd_uri = PPDUpload.ppd_uri(params[:printer][:host],@printer.ppd, params[:printer][:make])
        end
      end

      @printer.save!
      redirect_to admin_printers_path
    else
      # Do not enclose fields with errors in a div.field_with_errors
      # see http://guides.rubyonrails.org/active_record_validations_callbacks.html#customizing-the-error-messages-html
      ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
        html_tag
      end
      databag = Databag.find("printers")
      @makes = databag.empty? ? [] : databag.value.keys.sort
      databag = Databag.find("printers/#{@printer.make}")
      @models = databag.empty? ? [] : databag.value.keys.reject{ |k| k == "id" }.sort
      render :action => :edit
    end
  end

  def destroy
    nodes_to_clean = Node.search("automatic_printers_printers_spa_name:*#{params[:id]}*")
    if nodes_to_clean.kind_of? Node
      nodes_arr = []
      nodes_arr << nodes_to_clean
      nodes_to_clean = nodes_arr
    end

    nodes_to_clean.each do |node|
      node.normal['automatic_printers']['printers_spa'].delete({'name'=>params[:id]})
      if node.normal['automatic_printers']['printers_spa'].empty?
        node.normal.delete('automatic_printers')
        node.normal['default'].delete('printers_management::automatic_printers')
        node.run_list.delete('recipe[printers_management::automatic_printers]') 
      end
      node.save
    end
    Printer.delete!(params[:id])
    redirect_to admin_printers_path
  end

  # Returns the options for the model combo
  def models
    make = params[:make]
    @models = Databag.find("printers/#{make}").value.keys.reject{ |k| k == "id" }.sort
    render :layout => false
  end
end
