class Admin::PrintersController < ApplicationController
  before_filter :require_admin

  def index
    @printers = []
  end
end
