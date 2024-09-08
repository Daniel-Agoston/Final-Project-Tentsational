require_dependency Rails.root.join('app', 'search_algorithm', 'search_feature').to_s

class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :destroy]  # Ensure user is logged in for these actions
  before_action :set_categories, only: [:index, :new, :create]
  before_action :set_item, only: [:show, :destroy]
  before_action :authorize_user, only: [:destroy]

  # Predefined categories method
  def predefined_categories
    ['Clothing', 'Kitchen', 'Bedroom', 'Living Room', 'Garden', 'Other']
  end

  def index
    if params[:search] && params[:search][:query].present?
      @query = params[:search][:query].strip

      if predefined_categories.include?(@query)
        @items = Item.where(category: @query).order('name ASC')
      else
        search_service = SearchFeature.new(@query)
        @items = search_service.perform

        if @items.empty?
          # Fallback to showing items sorted by creation date
          @items = Item.order("created_at DESC")
        end
      end
    else
      # Show all items sorted by creation date if no search query
      @items = Item.order("created_at DESC")
    end

    # Generate markers for the items to display on the map
    @markers = @items.map do |item|
      {
        lat: item.latitude,
        lng: item.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { item: item }),
        marker_html: render_to_string(partial: "marker", locals: { item: item })
      }
    end
  end

  def show
    @review = Review.new
    @reviews = @item.reviews.order("created_at DESC")
    # Generate a marker for the item to display on the map
    @marker = [{
      lat: @item.latitude,
      lng: @item.longitude,
      info_window_html: render_to_string(partial: "info_window", locals: { item: @item }),
      marker_html: render_to_string(partial: "marker", locals: { item: @item })
    }]
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(get_item_params)
    @item.user = current_user

    # Simply save the item without any geocoding checks
    if @item.save
      redirect_to item_path(@item), notice: 'Item was successfully listed.'
    else
      Rails.logger.info "Item creation failed: #{@item.errors.full_messages}"
      flash.now[:alert] = nil
      set_categories
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logger.debug "Attempting to destroy item: #{@item.id}"

    if @item.bookings.any?
      logger.debug "Item has associated bookings. Destroying bookings first."

      @item.bookings.each do |booking|
        if booking.destroy
          logger.debug "Booking #{booking.id} destroyed successfully."
        else
          logger.debug "Failed to destroy booking #{booking.id}: #{booking.errors.full_messages}"
          redirect_to items_path, alert: 'Item could not be deleted due to booking dependencies.'
          return
        end
      end
    end

    if @item.destroy
      logger.debug "Item successfully destroyed."
      redirect_to dashboard_path, notice: 'Item was successfully deleted.'
    else
      logger.debug "Failed to destroy item: #{@item.errors.full_messages}"
      redirect_to items_path, alert: 'Item could not be deleted.'
    end
  end

  private

  def set_categories
    @categories = ['Clothing', 'Kitchen', 'Bedroom', 'Living Room', 'Garden', 'Other']
  end

  def get_item_params
    params.require(:item).permit(:name, :category, :description, :price, :photo, :address, :quantity, :latitude, :longitude)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def authorize_user
    unless current_user == @item.user || current_user.admin?
      redirect_back fallback_location: items_path, alert: "You cannot delete items listed by other users."
    end
  end
end
