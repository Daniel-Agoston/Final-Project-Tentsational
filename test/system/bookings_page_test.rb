require "application_system_test_case"

class BookingsPageTest < ApplicationSystemTestCase
  def setup
    # Create a user and log them in
    @user = User.create!(email: "test@example.com", password: "password")

    # Simulate visiting the login page and logging in
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Login'  # Use the correct capitalisation

    # Create an item to be booked
    @item = Item.new(
      name: 'Test Item',
      category: 'Test Category',
      description: 'This is a test item.',
      address: '123 Test Street, Test City',
      price: 100,
      quantity: 5,
      user: @user
    )

    # Create a temporary file to simulate an image upload
    file = Tempfile.new(['test_image', '.jpg'])
    file.binmode
    file.write(Base64.decode64('/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtREAAgEDAwIEAwUFBAQA AAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExGhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKUlRVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uLj5OXm5+jp6vHy8/T19vf4+fr/2gAMAwEAAhEDEQA/AMWf8AgP+E8z/B+//AFqHVP2L/NHpf8ACf/AIp7/f9v8A+0hqK2p/hfm2D/wCNFfoK7QAv/AJS8v0//ADn/qm/Y/8AhQ/+VIgD//2Q=='))
    file.rewind
    @item.photo.attach(io: file, filename: 'test_image.jpg', content_type: 'image/jpeg')
    @item.save!  # Save the item with the attached photo

    file.close
    file.unlink
  end

  test "visiting the bookings page and making a booking" do
    # Visit the new booking page for the item
    visit new_item_booking_path(@item)

    # Check that the page has loaded correctly with the item details
    assert_selector "h2", text: "Initial Basket"
    assert_text @item.name
    assert_text @item.description

    # Select a quantity and make a booking
    select '2', from: 'booking[quantity]'
    click_button 'Confirm Booking'

    # Verify that the booking was successful and the quantity was reduced
    booking = Booking.last
    assert_equal 2, booking.quantity
    assert_equal 3, @item.reload.quantity # Ensure the quantity was reduced
    assert_text "Booking was successfully created."
  end
end
