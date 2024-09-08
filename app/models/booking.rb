class Booking < ApplicationRecord
  belongs_to :item
  belongs_to :user

  validate :user_cannot_book_own_item
  validate :item_not_sold_out
  validate :sufficient_quantity_available

  after_create :reduce_item_quantity
  after_destroy :increase_item_quantity

  private

  def user_cannot_book_own_item
    if user_id == item.user_id
      errors.add(:base, "You cannot book your own item.")
    end
  end

  def item_not_sold_out
    if item.quantity.zero?
      errors.add(:base, "Sorry, this item is now sold out.")
      return false # Prevent further validations if the item is sold out
    end
  end

  def sufficient_quantity_available
    return if errors.present? # Skip this validation if there are already errors (e.g., item sold out)

    Rails.logger.debug "Booking validation started"
    Rails.logger.debug "Item ID: #{item.id}, Item Quantity: #{item.quantity.inspect}, Requested Quantity: #{quantity.inspect}"

    if item.quantity < quantity
      Rails.logger.debug "Insufficient quantity: Item Quantity: #{item.quantity}, Requested Quantity: #{quantity}"
      errors.add(:base, "Sorry, the requested quantity is not available.")
    else
      Rails.logger.debug "Sufficient quantity available"
    end
  end

  def reduce_item_quantity
    item.with_lock do
      new_quantity = item.quantity - quantity
      item.update!(quantity: new_quantity)
      update_item_status
    end
  end

  def increase_item_quantity(skip_validation: false, for_admin_deletion: false)
    item.with_lock do
      new_quantity = (item.quantity || 0) + quantity
      if skip_validation
        # Use update_column to skip validations during deletion scenarios
        item.update_column(:quantity, new_quantity)
        update_item_status_without_validation
      elsif for_admin_deletion
        # Additional logic for admin deletion scenarios
        item.update_column(:quantity, new_quantity)
        item.update_column(:status, 'deleted') # or any other status that makes sense
      else
        # Use update! to ensure validations and callbacks are run normally
        item.update!(quantity: new_quantity)
        update_item_status
      end
    end
  end

  def update_item_status
    item.update!(status: item.quantity.positive? ? 'available' : 'sold out')
  end
end
