namespace :geocode do
  desc "Backfill geocodes for existing items"
  task backfill: :environment do
    Item.where(latitude: nil, longitude: nil).find_each do |item|
      if item.address.present?
        results = Geocoder.search(item.address)
        if results.present?
          item.update(latitude: results.first.coordinates[0], longitude: results.first.coordinates[1])
          puts "Updated geocode for Item ID: #{item.id} to [#{item.latitude}, #{item.longitude}]"
        else
          puts "Geocode not found for Item ID: #{item.id} with address: #{item.address}"
        end
      end
    end
  end
end
