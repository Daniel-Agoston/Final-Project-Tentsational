# app/models/booking.rb
class Booking < ApplicationRecord
  # Establishes associations with the Item and User models.
  belongs_to :item
  belongs_to :user

  # Custom validations to ensure proper booking rules are followed.
  validate :user_cannot_book_own_item
  validate :item_not_sold_out
  validate :sufficient_quantity_available

  # Callbacks to adjust item quantity after a booking is created or destroyed.
  after_create :reduce_item_quantity
  after_destroy :increase_item_quantity

  private

  # Validation to prevent users from booking their own items.
  def user_cannot_book_own_item
    if user_id == item.user_id
      errors.add(:base, "You cannot book your own item.") # Adds an error message to the base if the user tries to book their own item.
    end
  end

  # Validation to check if the item is sold out.
  def item_not_sold_out
    if item.quantity.zero?
      errors.add(:base, "Sorry, this item is now sold out.") # Adds an error message if the item is sold out.
      return false # Prevent further validations if the item is sold out.
    end
  end

  # Validation to ensure there is sufficient quantity available for the booking.
  def sufficient_quantity_available
    return if errors.present? # Skip this validation if there are already errors (e.g., item sold out).

    # Logging for debugging purposes.
    Rails.logger.debug "Booking validation started"
    Rails.logger.debug "Item ID: #{item.id}, Item Quantity: #{item.quantity.inspect}, Requested Quantity: #{quantity.inspect}"

    if item.quantity < quantity
      Rails.logger.debug "Insufficient quantity: Item Quantity: #{item.quantity}, Requested Quantity: #{quantity}"
      errors.add(:base, "Sorry, the requested quantity is not available.") # Adds an error message if the requested quantity exceeds available quantity.
    else
      Rails.logger.debug "Sufficient quantity available"
    end
  end

  # Callback to reduce the quantity of the item after a booking is created.
  def reduce_item_quantity
    item.with_lock do
      new_quantity = item.quantity - quantity # Calculates the new quantity after booking.
      item.update!(quantity: new_quantity) # Updates the item quantity.
      update_item_status # Updates the item's status based on the new quantity.
    end
  end

  # Callback to increase the quantity of the item after a booking is destroyed.
  def increase_item_quantity(skip_validation: false, for_admin_deletion: false)
    item.with_lock do
      new_quantity = (item.quantity || 0) + quantity # Calculates the new quantity after cancellation.
      if skip_validation
        # Use update_column to skip validations during deletion scenarios.
        item.update_column(:quantity, new_quantity)
        update_item_status_without_validation # Updates item status without triggering validations.
      elsif for_admin_deletion
        # Additional logic for admin deletion scenarios.
        item.update_column(:quantity, new_quantity)
        item.update_column(:status, 'deleted') # Updates the status to 'deleted' or any other relevant status.
      else
        # Use update! to ensure validations and callbacks are run normally.
        item.update!(quantity: new_quantity)
        update_item_status # Updates the item's status based on the new quantity.
      end
    end
  end

  # Method to update the item's status based on its quantity.
  def update_item_status
    item.update!(status: item.quantity.positive? ? 'available' : 'sold out') # Sets the status to 'available' or 'sold out'.
  end
end
