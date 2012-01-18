class Admin::PrintersController < ApplicationController
  before_filter :require_admin

  def index
    databag = Databag.find("available_printers")
    @printers = databag.empty? ? [] : databag.value
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
        basename = PPDUpload.save(params[:printer][:ppd_file], make, model)
        @printer.ppd = basename
        @printer.ppd_uri = PPDUpload.ppd_uri(basename, make, model)
        @printer.create
      else
        printer = Databag.find("printers/#{make}").value[model]
        if printer["recommended_ppd"].present?
          @printer.ppd = printer["recommended_ppd"]
          @printer.ppd_uri = PPDUpload.ppd_uri(@printer.ppd, make, model)
        end
        @printer.create
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

  # Returns the options for the model combo
  def models
    make = params[:make]
    @models = Databag.find("printers/#{make}").value.keys.reject{ |k| k == "id" }.sort
    render :layout => false
  end
end
