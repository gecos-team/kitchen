class Admin::PrintersController < ApplicationController
  before_filter :require_admin

  def index
    @printers = [] # Printer.all
  end

  def new
    @printer = Printer.new
    databag = Databag.find("printers")
    @makes = databag.empty? ? [] : databag.value.keys.sort
  end

  def create
    @printer = Printer.new(params[:printer])
    if @printer.valid? and @printer.create
      redirect_to admin_printers_path
    else
      # Do not enclose fields with errors in a div.field_with_errors
      # see http://guides.rubyonrails.org/active_record_validations_callbacks.html#customizing-the-error-messages-html
      ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
        html_tag
      end
      @makes = Databag.find("printers").value.keys.sort
     if (make = params[:printer][:make]).present?
        @models = Databag.find("printers/#{make}").value.keys.reject{ |k| k == "id" }.sort
      end
      render :action => :new
    end
  end

  # Returns the options for the model combo
  def show
    make = params[:id]
    @models = Databag.find("printers/#{make}").value.keys.reject{ |k| k == "id" }.sort
    render :layout => false
  end
end
