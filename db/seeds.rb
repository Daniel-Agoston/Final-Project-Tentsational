# Clear existing data
Booking.destroy_all
Item.destroy_all
User.destroy_all

# Admin user
User.create!(email: 'admin@example.com', password: 'London2424', admin: true)

# Default users
users = [
  { email: 'alice@example.com', password: 'password' },
  { email: 'marco@example.com', password: 'password' },
  { email: 'jordan@example.com', password: 'password' },
  { email: 'daniel@example.com', password: 'password' },
  { email: 'rory@example.com', password: 'password' },
  { email: 'ben@example.com', password: 'password' }
]

users.each { |user_data| User.create!(user_data) }

# Items for these users
items = [
  { user: User.find_by(email: 'alice@example.com'), address: "Hoxton, London", description: "A camping tent", name: 'Tent', category: "Clothing", price: 1, quantity: 1, qty_listed: 1, image_url: 'https://res.cloudinary.com/dwkdsiawn/image/upload/v1716957829/development/gb3lvwdkm3wljfss9hts.jpg' },
  { user: User.find_by(email: 'marco@example.com'), address: "Soho, London", description: "Sleeping bag for you", name: 'Sleeping Bag', category: "Kitchen", price: 5, quantity: 3, qty_listed: 3, image_url: 'https://res.cloudinary.com/dwkdsiawn/image/upload/v1716957908/development/d0mjpmip5y1ocobsrhfv.jpg' },
  { user: User.find_by(email: 'jordan@example.com'), address: "Bali, Indonesia", description: "An amazing comfy chair", name: 'Camping Chair', category: "Bedroom", price: 9, quantity: 2, qty_listed: 2, image_url: 'https://res.cloudinary.com/dwkdsiawn/image/upload/v1716959118/development/zfmu5ispas1oy4wrpo3n.jpg' },
  { user: User.find_by(email: 'daniel@example.com'), address: "Sao Paulo, Brazil", description: "Magical outfit for you and your friends", name: 'Unicorn Outfit', category: "Garden", price: 5, quantity: 5, qty_listed: 5, image_url: 'https://res.cloudinary.com/dwkdsiawn/image/upload/v1716959116/development/enhnfa64awxh0ajxudrw.webp' },
  { user: User.find_by(email: 'rory@example.com'), address: "Small Heath, UK", description: "It's getting hot in here", name: 'Camping Stove', category: "Garden", price: 3, quantity: 1, qty_listed: 1, image_url: 'https://res.cloudinary.com/dwkdsiawn/image/upload/v1716959240/development/brss9zvrgskum1gajv1t.jpg' },
  { user: User.find_by(email: 'ben@example.com'), address: "Bondi Beach, Australia", description: "Who'd of thunk it", name: 'Surprise', category: "Living Room", price: 0, quantity: 4, qty_listed: 4, image_url: 'https://res.cloudinary.com/dwkdsiawn/image/upload/v1716959379/development/kcgnvxiptthpddrpdhzv.webp' }
]

items.each do |item_data|
  item = Item.new(
    user: item_data[:user],
    description: item_data[:description],
    name: item_data[:name],
    category: item_data[:category],
    price: item_data[:price],
    address: item_data[:address],
    quantity: item_data[:quantity]
  )

  file = URI.open(item_data[:image_url])
  item.photo.attach(io: file, filename: File.basename(item_data[:image_url]), content_type: 'image/jpeg/webp')

  if item.save
    puts "Item '#{item.name}' created successfully with coordinates: #{item.latitude}, #{item.longitude}."
  else
    puts "Failed to create item: #{item_data[:name]}. Errors: #{item.errors.full_messages.join(", ")}"

    # Additional Debugging
    puts "Debugging Geocoder for address '#{item_data[:address]}':"
    geocoder_results = Geocoder.search(item_data[:address])
    puts "Geocoder results: #{geocoder_results.map(&:data).inspect}"
  end
end
