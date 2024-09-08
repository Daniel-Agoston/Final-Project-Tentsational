class PagesController < ApplicationController
  def home
    @search = params[:search]
  end

  def new
    @item = Item.new
  end
end
