# to run this test: rails test test/models/item_test.rb in git/command line

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    # Ensure User model is correctly referenced and loaded
    @user = User.create(email: 'test@example.com', password: 'password')
    @admin = User.create(email: 'admin@example.com', password: 'password', admin: true)
    @other_user = User.create(email: 'other@example.com', password: 'password')

    # Set up an item with a photo attached
    @item = Item.new(
      name: 'Test Item',
      category: 'Test Category',
      description: 'This is a test item.',
      address: '123 Test Street, Test City',
      price: 100,
      quantity: 1,
      user: @user
    )

    # Valid JPEG base64 encoded image data
    jpeg_image_data = Base64.decode64('/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0a' \
                                      'HBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIy' \
                                      'MjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEB' \
                                      'AxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQA AAF9' \
                                      'AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6' \
                                      'Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ip' \
                                      'qrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEA')

    file = Tempfile.new(['test_image', '.jpg'])
    file.binmode
    file.write(jpeg_image_data)
    file.rewind

    @item.photo.attach(io: file, filename: 'test_image.jpg', content_type: 'image/jpeg')
    @item.save!
  end

  # Test that quantity must be positive on creation
  test 'initial quantity must be positive' do
    @item = Item.new(
      name: 'Test Item',
      category: 'Test Category',
      description: 'This is a test item.',
      address: '123 Test Street, Test City',
      price: 100,
      quantity: 0, # Invalid quantity
      user: @user
    )

    # Attempt to save the item and assert it does not save successfully
    assert_not @item.save, "Saved the item with a quantity less than 1"

    # Verify that the validation message is present
    assert_includes @item.errors[:quantity], 'must be at least 1 when the item is created.'
  end

  # Test that price must be valid
  test 'price must be valid' do
    @item.price = -1
    assert_not @item.valid?
    assert_includes @item.errors[:price], 'must be either 0 or a positive number.'
  end

  # Test that status updates to sold out when quantity is zero
  test 'status should be sold out when quantity is zero' do
    ActiveRecord::Base.transaction do
      @item.update(quantity: 0)
      @item.save
      assert_equal 'sold out', @item.status, "Item status should be 'sold out' when quantity is zero"
      raise ActiveRecord::Rollback # Ensures the transaction is rolled back
    end
  end

  # Test that status updates to available when quantity is greater than zero
  test 'status should be available when quantity is greater than zero' do
    @item.update(quantity: 5)
    assert_equal 'available', @item.reload.status
  end

  # Test that unauthorized users cannot delete an item
  test 'other user cannot delete item' do
    assert_no_difference('Item.count') do
      assert_raises(ActiveRecord::RecordNotDestroyed) do
        Current.user = @other_user
        @item.destroy!
      end
    end
    assert_includes @item.errors[:base], "You are not authorized to delete this item."
  end

  # Test that an admin can delete the item
  test 'admin can delete item' do
    assert_difference('Item.count', -1) do
      Current.user = @admin
      @item.destroy
    end
  end

  # Test that the owner of the item can delete it
  test 'owner can delete item' do
    assert_difference('Item.count', -1) do
      Current.user = @user
      @item.destroy
    end
  end
end
