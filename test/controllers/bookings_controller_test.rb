require "test_helper"
require "base64"
require "tempfile"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers # Include Devise test helpers

  setup do
    # Create two users: one for the item owner and another for the booking user
    @owner = User.create!(email: 'owner@example.com', password: 'password')
    @user = User.create!(email: 'test@example.com', password: 'password')

    # Sign in the user who will make the booking
    sign_in @user

    @item = Item.new(
      name: 'Test Item',
      description: 'Test Description',
      category: 'Test Category',
      address: 'Test Address',
      price: 5.0,
      quantity: 1,
      user: @owner # Assign the item to the owner
    )

    # Mock image upload for Item
    file = Tempfile.new(['test_image', '.jpg'])
    file.binmode
    file.write(Base64.decode64('/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtREAAgEDAwIEAwUFBAQA AAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExGhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKUlRVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uLj5OXm5+jp6vHy8/T19vf4+fr/2gAMAwEAAhEDEQA/AMWf8AgP+E8z/B+//AFqHVP2L/NHpf8ACf/AIp7/f9v8A+0hqK2p/hfm2D/wCNFfoK7QAv/AJS8v0//ADn/qm/Y/8AhQ/+VIgD//2Q=='))
    file.rewind
    @item.photo.attach(io: file, filename: 'test_image.jpg', content_type: 'image/jpeg')
    @item.save!

    file.close
    file.unlink

    @valid_booking_params = {
      item_id: @item.id,
      booking: {
        quantity: 1,
        start_date: Date.today,
        end_date: Date.today + 7
      }
    }

    @invalid_booking_params = {
      item_id: @item.id,
      booking: {
        quantity: 0, # Invalid quantity
        start_date: Date.today,
        end_date: Date.today - 1 # Invalid date range
      }
    }
  end

  test "should get new" do
    get new_item_booking_url(@item)
    assert_response :success
    assert_select "form" # Check for the presence of a form on the page
  end

  test "should create booking with valid parameters" do
    assert_difference('Booking.count', 1) do
      post item_bookings_url(@item), params: @valid_booking_params
    end
    assert_redirected_to dashboard_path # Check that the user is redirected after a successful booking
    assert_equal 'Success! Your item(s) are coming home! 👍', flash[:notice]
  end

  test "should destroy booking if user is owner or admin" do
    @booking = Booking.create!(user: @user, item: @item, quantity: 1, start_date: Date.today, end_date: Date.today + 7)
    assert_difference('Booking.count', -1) do
      delete booking_url(@booking)
    end
    assert_redirected_to dashboard_path
    assert_equal 'Item was successfully cancelled.', flash[:notice]
  end

  test "should not destroy booking if user is not owner" do
    @other_user = User.create!(email: 'other@example.com', password: 'password')
    sign_in @other_user
    @booking = Booking.create!(user: @user, item: @item, quantity: 1, start_date: Date.today, end_date: Date.today + 7) # Booking created by another user
    assert_no_difference('Booking.count') do
      delete booking_url(@booking)
    end
    assert_redirected_to dashboard_path
    assert_equal 'You are not allowed to cancel this booking.', flash[:alert]
  end
end
