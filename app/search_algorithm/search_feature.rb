# app/search_algorithm/search_feature.rb
# class SearchFeature
#   require 'geocoder'

#   def initialize(query, category: nil)
#     @query = query.strip.downcase
#     @category = category
#   end

#   # Main method to perform search
#   def perform
#     if @query.blank? && @category.present?
#       # If only category is present, search by category
#       search_items_alphabetically_by_category
#     elsif valid_location?
#       search_items_by_relevance_and_proximity
#     elsif @query.present?
#       search_items_strictly_alphabetically
#     else
#       search_items_alphabetically
#     end
#   end

#   private

#   # Validate the location using Geocoder and ensure it is a valid place
#   def valid_location?
#     return false if @query.blank?

#     # Perform Geocoder search
#     results = Geocoder.search(@query)

#     # Debugging: Output the raw results from Geocoder
#     puts "Geocoder search results for '#{@query}':"
#     results.each do |result|
#       puts " - Relevance: #{result.data['relevance']}, Place types: #{result.data['place_type']}, Coordinates: #{result.coordinates.inspect}"
#     end

#     return false if results.empty?

#     result = results.first
#     relevance = result.data['relevance'].to_f
#     place_types = result.data['place_type'] || []

#     valid_place_types = %w[
#       address locality neighborhood place region country suburb district city
#       village hamlet town county state province municipality ward metro borough
#     ]

#     valid_postal_types = %w[
#       postcode zip zip_code cep european_postal_code postal_code
#     ]

#     is_valid_place = (place_types & valid_place_types).any?
#     is_valid_postcode = (place_types & valid_postal_types).any?

#     relevance >= 0.1 && (is_valid_place || is_valid_postcode)
#   end

#   # Search items and sort by relevance and proximity using SQL for efficiency
#   def search_items_by_relevance_and_proximity
#     results = Geocoder.search(@query)
#     return [] if results.empty?

#     location = results.first.coordinates # [latitude, longitude]

#     # Construct base query
#     items = Item.where.not(latitude: nil, longitude: nil)

#     # Filter by category if provided
#     items = items.where(category: @category) if @category.present?

#     # Calculate distances using plain SQL with latitude and longitude fields
#     items = items.select(
#       "items.*, (6371 * acos(cos(radians(#{location[0]})) * cos(radians(items.latitude)) * cos(radians(items.longitude) - radians(#{location[1]})) + sin(radians(#{location[0]})) * sin(radians(items.latitude)))) AS distance"
#     ).order(Arel.sql("CASE WHEN lower(items.name) = '#{@query.downcase}' THEN 0 ELSE 1 END, distance ASC"))

#     # Return items as an array with virtual attribute distance
#     items.each do |item|
#       item.define_singleton_method(:distance) { item['distance'] }
#     end
#     items
#   end

#   # Base query for fetching items, optionally filtered by category
#   def base_item_query
#     items = Item.all
#     items = items.where(category: @category) if @category.present?
#     items
#   end

#   # Search items strictly alphabetically by name when a search term is provided but no valid location
#   def search_items_strictly_alphabetically
#     items = base_item_query

#     # Filter items whose names contain the search term using case-insensitive matching
#     items = items.where('name ILIKE ?', "%#{@query}%")

#     # Sort items strictly alphabetically by name
#     items.order('name ASC')
#   end

#   # Search items strictly alphabetically by category if no search term is provided
#   def search_items_alphabetically_by_category
#     items = base_item_query
#     items.order('name ASC')
#   end

#   # Search items and sort alphabetically if no valid location or relevance
#   def search_items_alphabetically
#     items = base_item_query
#     items.order('name ASC')
#   end
# end

class SearchFeature
  require 'geocoder'

  def initialize(query, category: nil)
    @query = query.strip.downcase
    @category = category
    @item_query, @location_query = parse_query(@query)
  end

  # Main method to perform search
  def perform
    if @item_query.blank? && @location_query.present?
      # If only location is present, search by location proximity
      search_items_by_location
    elsif valid_location?
      search_items_by_relevance_and_proximity
    elsif @item_query.present?
      search_items_by_name
    else
      search_items_alphabetically
    end
  end

  private

  # Split the search query into item and location
  def parse_query(query)
    # A simple heuristic to split item and location queries
    split_query = query.split(' in ')
    item_query = split_query[0].strip
    location_query = split_query[1].strip if split_query.size > 1
    [item_query, location_query]
  end

  # Validate the location using Geocoder and ensure it is a valid place
  def valid_location?
    return false if @location_query.blank?

    # Perform Geocoder search
    results = Geocoder.search(@location_query)

    # Return false if results are empty or not valid
    return false if results.empty?

    result = results.first
    relevance = result.data['relevance'].to_f
    place_types = result.data['place_type'] || []

    valid_place_types = %w[
      address locality neighborhood place region country suburb district city
      village hamlet town county state province municipality ward metro borough
    ]

    valid_postal_types = %w[
      postcode zip zip_code cep european_postal_code postal_code
    ]

    is_valid_place = (place_types & valid_place_types).any?
    is_valid_postcode = (place_types & valid_postal_types).any?

    relevance >= 0.1 && (is_valid_place || is_valid_postcode)
  end

  # Search items by relevance and proximity using SQL for efficiency
  def search_items_by_relevance_and_proximity
    results = Geocoder.search(@location_query)
    return [] if results.empty?

    location = results.first.coordinates # [latitude, longitude]

    # Construct base query
    items = base_item_query

    # Calculate distances using plain SQL with latitude and longitude fields
    items = items.select(
      "items.*, (6371 * acos(cos(radians(#{location[0]})) * cos(radians(items.latitude)) * cos(radians(items.longitude) - radians(#{location[1]})) + sin(radians(#{location[0]})) * sin(radians(items.latitude)))) AS distance"
    ).order(Arel.sql("CASE WHEN lower(items.name) = '#{@item_query.downcase}' THEN 0 ELSE 1 END, distance ASC"))

    # Return items as an array with the virtual attribute 'distance'
    items.each do |item|
      item.define_singleton_method(:distance) { item['distance'] }
    end
    items
  end

  # Search items strictly by name if a valid location is not provided
  def search_items_by_name
    items = base_item_query
    items = items.where('name ILIKE ?', "%#{@item_query}%")
    items.order('name ASC')
  end

  # Search items strictly alphabetically by category if no search term is provided
  def search_items_by_location
    items = base_item_query
    items.order('name ASC')
  end

  # Base query for fetching items, optionally filtered by category
  def base_item_query
    items = Item.all
    items = items.where(category: @category) if @category.present?
    items
  end

  # Search items and sort alphabetically if no valid location or relevance
  def search_items_alphabetically
    items = base_item_query
    items.order('name ASC')
  end
end
