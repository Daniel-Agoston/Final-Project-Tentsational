# test/services/search_feature_test.rb
require 'test_helper'
require 'base64'

class SearchFeatureTest < ActiveSupport::TestCase
  # Class-level variable to manage temp files
  @@temp_files = []

  def setup
    # Create a user to associate with items
    @owner = User.create!(email: 'owner@example.com', password: 'password')

    # Create test items with different names, descriptions, photos, and locations
    @item1 = Item.new(
      name: "Tent",
      category: "Camping",
      description: "A great tent for camping.",
      address: "London",
      price: 100,
      quantity: 10,
      user: @owner
    )
    attach_mock_photo(@item1)
    @item1.save!

    @item2 = Item.new(
      name: "Tent Cover",
      category: "Camping",
      description: "A cover for your tent.",
      address: "Paris",
      price: 50,
      quantity: 5,
      user: @owner
    )
    attach_mock_photo(@item2)
    @item2.save!

    @item3 = Item.new(
      name: "T-shirt",
      category: "Clothing",
      description: "A comfortable t-shirt.",
      address: "Berlin",
      price: 20,
      quantity: 15,
      user: @owner
    )
    attach_mock_photo(@item3)
    @item3.save!

    @item4 = Item.new(
      name: "Lantern",
      category: "Camping",
      description: "A bright lantern for camping.",
      address: "London",
      price: 30,
      quantity: 8,
      user: @owner
    )
    attach_mock_photo(@item4)
    @item4.save!

    # Ensure items have latitude and longitude after geocoding
    [@item1, @item2, @item3, @item4].each(&:geocode)
  end

  # Method to attach a mock photo to an item
  def attach_mock_photo(item)
    file = Tempfile.new(['test_image', '.jpg'])
    @@temp_files << file

    file.binmode
    file.write(Base64.decode64('/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtREAAgEDAwIEAwUFBAQA AAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExGhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKUlRVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uLj5OXm5+jp6vHy8/T19vf4+fr/2gAMAwEAAhEDEQA/AMWf'))
    file.rewind
    item.photo.attach(io: file, filename: 'test_image.jpg', content_type: 'image/jpeg')
  end

  # Clean up temp files after all tests are run
  def teardown
    @@temp_files.each do |file|
      file.close
      file.unlink
    end
  end

  test "search with valid location and search term" do
    search_service = SearchFeature.new("Tent", category: "Camping")
    results = search_service.perform

    # Check both relevance (exact match) and proximity (London over Paris)
    assert_equal ["Tent", "Tent Cover", "Lantern"], results.map(&:name), "Items should be sorted by relevance and proximity when both location and search term are provided."
  end

  test "search with valid search term but no location" do
    search_service = SearchFeature.new("Tent")
    results = search_service.perform

    # Ensure the correct items are returned (ignore order)
    assert_equal ["Tent", "Tent Cover", "Lantern", "T-shirt"].sort, results.map(&:name).sort, "Items should include those matching the search term when no valid location."
  end

  test "search with no search term and category" do
    search_service = SearchFeature.new("", category: "Camping")
    results = search_service.perform

    # Ensure the correct items are returned (ignore order)
    assert_equal ["Lantern", "Tent", "Tent Cover"].sort, results.map(&:name).sort, "Items should be filtered by category when no search term is provided but a valid category is given."
  end

  test "search with no search term and no category" do
    search_service = SearchFeature.new("")
    results = search_service.perform

    # Ensure the correct items are returned (ignore order)
    assert_equal ["Lantern", "T-shirt", "Tent", "Tent Cover"].sort, results.map(&:name).sort, "Items should be returned without filtering when no search term or category is provided."
  end

  test "search with invalid query" do
    search_service = SearchFeature.new("InvalidQuery")
    results = search_service.perform

    assert_empty results, "No items should be returned when an invalid query is provided."
  end
end
