# app/jobs/geocode_item_job.rb
class GeocodeItemJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find_by(id: item_id)

    # Return early if item is not found or address is not present
    return unless item&.address.present? && item.latitude.blank? && item.longitude.blank?

    begin
      # Perform geocoding
      results = Geocoder.search(item.address)

      if results.present? && results.first.coordinates.present?
        # Update item with geocoded coordinates
        item.update(latitude: results.first.coordinates[0], longitude: results.first.coordinates[1])
        Rails.logger.info "Geocode successful for Item ID: #{item_id} with address: #{item.address}"
      else
        # Log if geocoding fails or no results are found
        Rails.logger.warn "Geocode not found for Item ID: #{item_id} with address: #{item.address}"
      end
    rescue => e
      # Log any exceptions that occur during geocoding
      Rails.logger.error "Geocoding failed for Item ID: #{item_id} with error: #{e.message}"
    end
  end
end
