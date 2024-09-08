# app/controllers/bookings_controller.rb
class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:new, :create, :show]
  before_action :set_booking, only: [:destroy]

  def index
    @items = current_user.items
    @bookings = current_user.bookings
  end

  def new
    @booking = Booking.new
    @booking.user_id = current_user.id
  end

  def create
    @booking = Booking.new(get_booking_params)
    @booking.user = current_user
    @booking.item = @item

    if @booking.save
      redirect_to dashboard_path, notice: "Success! Your item(s) are coming home! 👍"
    else
      # Render the new booking page with error messages
      flash.now[:alert] = @booking.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @booking.user == current_user || current_user.admin?
      @booking.destroy
      redirect_to dashboard_path, notice: 'Item was successfully cancelled.'
    else
      redirect_to dashboard_path, alert: 'You are not allowed to cancel this booking.'
    end
  end

  private

  def get_booking_params
    params.require(:booking).permit(:start_date, :end_date, :quantity)
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
