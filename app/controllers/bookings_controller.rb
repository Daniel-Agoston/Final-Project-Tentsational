# app/controllers/bookings_controller.rb
class BookingsController < ApplicationController
  # Ensures that a user is authenticated before any action in this controller is executed.
  before_action :authenticate_user!
  # Sets the item instance variable for the specified actions.
  before_action :set_item, only: [:new, :create, :show]
  # Sets the booking instance variable for the destroy action.
  before_action :set_booking, only: [:destroy]

  # Displays the list of items and bookings associated with the current user.
  def index
    @items = current_user.items # Fetches the items belonging to the current user.
    @bookings = current_user.bookings # Fetches the bookings made by the current user.
  end

  # Initializes a new booking object for the new booking form.
  def new
    @booking = Booking.new # Creates a new, empty booking object.
    @booking.user_id = current_user.id # Pre-sets the user ID to the current user.
  end

  # Creates a new booking and associates it with the current user and the selected item.
  def create
    @booking = Booking.new(get_booking_params) # Initializes a new booking with the permitted parameters.
    @booking.user = current_user # Associates the booking with the current user.
    @booking.item = @item # Associates the booking with the selected item.

    if @booking.save
      # If booking is successfully saved, redirect to the dashboard with a success message.
      redirect_to dashboard_path, notice: "Success! Your item(s) are coming home! 👍"
    else
      # If there are errors, display them and render the new booking form again.
      flash.now[:alert] = @booking.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  # Deletes an existing booking if the user is authorized.
  def destroy
    if @booking.user == current_user || current_user.admin?
      # If the current user is the owner of the booking or an admin, destroy the booking.
      @booking.destroy
      redirect_to dashboard_path, notice: 'Item was successfully cancelled.'
    else
      # If not authorized, redirect with an alert message.
      redirect_to dashboard_path, alert: 'You are not allowed to cancel this booking.'
    end
  end

  private

  # Strong parameters: allows only the specified parameters to be used for creating or updating bookings.
  def get_booking_params
    params.require(:booking).permit(:start_date, :end_date, :quantity)
  end

  # Finds and sets the item based on the item_id parameter.
  def set_item
    @item = Item.find(params[:item_id])
  end

  # Finds and sets the booking based on the id parameter.
  def set_booking
    @booking = Booking.find(params[:id])
  end
end
