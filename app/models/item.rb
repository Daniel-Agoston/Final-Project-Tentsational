class Item < ApplicationRecord
  belongs_to :user
  has_one_attached :photo
  has_many :reviews, dependent: :destroy
  has_many :bookings, dependent: :destroy

  # Validations for required fields
  validates :name, presence: true
  validates :category, presence: true
  validates :description, presence: true
  validates :address, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true }
  validate :initial_quantity_must_be_positive, on: :create
  validate :price_must_be_valid

  # Active Storage validations
  validates :photo, attached: true, content_type: %i[png jpg jpeg webp], on: [:create, :update], unless: :skip_photo_validation?

  # Callbacks
  before_save :update_item_status
  before_destroy :ensure_user_can_delete_item
  before_create :set_qty_listed  # New callback to set qty_listed on creation

  # Enqueue Geocoding Job after creation
  after_create_commit :enqueue_geocoding_job

  private

  # Method to enqueue a background job for geocoding
  def enqueue_geocoding_job
    GeocodeItemJob.perform_later(id)
  end

  # Method to set the quantity listed for the item during creation
  def set_qty_listed
    self.qty_listed = quantity
  end

  # Validation method to ensure initial quantity is positive
  def initial_quantity_must_be_positive
    Rails.logger.debug "Validating initial quantity: #{quantity.inspect}"
    if quantity.nil? || quantity < 1
      errors.add(:quantity, "must be at least 1 when the item is created.")
    end
  end

  # Validation method to ensure the price is within a valid range
  def price_must_be_valid
    if price.blank? || price.to_f < 0 || price.to_f > 10
      errors.add(:price, "must be between 0 and 10 pounds.")
    end
  end

  # Callback method to update item status based on quantity
  def update_item_status
    self.status = quantity.zero? ? 'sold out' : 'available'
  end

  # Callback method to ensure only authorized users can delete the item
  def ensure_user_can_delete_item
    return if Current.user.nil? # Skip the check during seeding

    unless user == Current.user || Current.user&.admin?
      errors.add(:base, "You are not authorized to delete this item.")
      throw :abort
    end
  end

  # Method to determine if photo validation should be skipped
  def skip_photo_validation?
    destroyed? # This returns true if the item is marked for destruction
  end
end
