class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @items = current_user.items
    @bookings = current_user.bookings
  end
end
