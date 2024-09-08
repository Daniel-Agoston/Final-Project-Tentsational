require 'test_helper'
require 'base64'

class BookingTest < ActiveSupport::TestCase
  def setup
    @owner = User.create!(email: 'owner@example.com', password: 'password')
    @user = User.create!(email: 'user@example.com', password: 'password')

    @item = Item.new(
      name: 'Test Item',
      category: 'Test Category',
      description: 'This is a test item.',
      address: '123 Test Street, Test City',
      price: 100,
      quantity: 5,
      user: @owner
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
  end

  test "should reduce quantity when booking is created" do
    booking = Booking.create!(item: @item, user: @user, quantity: 5)
    assert_equal 0, @item.reload.quantity, "Item quantity should be reduced to zero after booking all available stock."
    assert_equal 'sold out', @item.reload.status, "Item should be marked as sold out."
  end

  test "should prevent booking if item is sold out" do
    @item.update(quantity: 0)
    booking = Booking.new(item: @item, user: @user, quantity: 1)
    assert_not booking.valid?, "Booking should be invalid if item is sold out."
    assert_includes booking.errors[:base], "Sorry, this item is now sold out."
  end

  test "should allow booking if sufficient quantity available" do
    booking = Booking.create!(item: @item, user: @user, quantity: 3)
    assert booking.persisted?, "Booking should be successful when quantity is sufficient."
    assert_equal 2, @item.reload.quantity, "Item quantity should be reduced correctly."
  end

  test "should increase quantity when booking is cancelled" do
    booking = Booking.create!(item: @item, user: @user, quantity: 2)
    assert_difference('@item.reload.quantity', 2) do
      booking.destroy
    end
  end

  test "should prevent booking if quantity exceeds available" do
    booking = Booking.new(item: @item, user: @user, quantity: 10)
    assert_not booking.valid?, "Booking should be invalid if quantity exceeds available."
    assert_includes booking.errors[:base], "Sorry, the requested quantity is not available."
  end

  test "should prevent overselling item when two users book simultaneously" do
    user2 = User.create!(email: 'user2@example.com', password: 'password')

    booking1 = nil
    booking2 = nil

    Item.transaction do
      booking1 = Booking.create!(item: @item, user: @user, quantity: 5)
      booking2 = Booking.new(item: @item, user: user2, quantity: 1)
      assert_not booking2.valid?, "Booking should be invalid if item is sold out."
    end

    assert booking1.persisted?, "Booking 1 should be created successfully"
  end
end
