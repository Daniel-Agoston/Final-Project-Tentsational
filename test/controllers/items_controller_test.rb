require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers # Add this line

  # Set up a mock image file and an item with that image attached for testing
  def setup
    @user = User.create!(email: "test@example.com", password: "password") # Ensure User is created for Item
    sign_in @user # Sign in the user

    @item = Item.new(
      name: "Test Item",
      category: "Clothing",
      description: "A test item description",
      price: 10,
      quantity: 5,
      address: "123 Test Street, Test City"
    )

    # Mock image upload for Item
    file = Tempfile.new(['test_image', '.jpg'])
    file.binmode
    file.write(Base64.decode64('/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtREAAgEDAwIEAwUFBAQA AAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExGhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKUlRVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uLj5OXm5+jp6vHy8/T19vf4+fr/2gAMAwEAAhEDEQA/AMWf8AgP+E8z/B+//AFqHVP2L/NHpf8ACf/AIp7/f9v8A+0hqK2p/hfm2D/wCNFfoK7QAv/AJS8v0//ADn/qm/Y/8AhQ/+VIgD//2Q=='))
    file.rewind
    @item.photo.attach(io: file, filename: 'test_image.jpg', content_type: 'image/jpeg')
    @item.user = @user
    @item.save!

    file.close
    file.unlink
  end

  test "should return items sorted by proximity when searching by location" do
    get items_path(search: { query: "Test City" })
    assert_response :success
    # Your assertions for proximity sorting
  end

  test "should return items only in the specified category when searching by category" do
    get items_path(search: { query: "Clothing" })
    assert_response :success
    # Your assertions for category filtering
  end

  test "should return items matching the name when searching by item name" do
    get items_path(search: { query: "Test Item" })
    assert_response :success
    # Your assertions for name filtering
  end

  test "should handle no items found gracefully" do
    # Trigger the search action with a query that should result in no items found
    get items_path, params: { search: { query: "nonexistent_item" } }
    assert_response :success

    # Add debug output to see the state of @items
    puts "Items present in test: #{@controller.instance_variable_get(:@items).inspect}"  # Debugging: Inspect @items from the controller

    # Check the response body for the expected message
    assert_match "No items found", @response.body
  end
end
