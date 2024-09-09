require "test_helper"

class GeocodeItemJobTest < ActiveJob::TestCase
  def setup
    @user = User.create!(email: 'test@example.com', password: 'password')

    @item = Item.new(
      name: "Test Item",
      address: "Test Address",
      category: "Camping",
      description: "A test item description.",
      quantity: 1,
      price: 5
    )

    # Attach a mock photo
    attach_mock_photo(@item)

    @item.user = @user
    @item.save!
  end

  test "should create item with valid attributes" do
    assert @item.persisted?, "Item should be persisted in the database"
    assert_equal "Test Item", @item.name, "Item name should be 'Test Item'"
    assert_equal "Test Address", @item.address, "Item address should be 'Test Address'"
    assert_equal "Camping", @item.category, "Item category should be 'Camping'"
    assert_equal "A test item description.", @item.description, "Item description should be 'A test item description.'"
    assert_equal 1, @item.quantity, "Item quantity should be 1"
    assert_equal 5, @item.price, "Item price should be 5"
    assert @item.photo.attached?, "Item should have a photo attached"
    assert_equal @user, @item.user, "Item user should be the created user"
  end

  private

  def attach_mock_photo(item)
    file = Tempfile.new(['test_image', '.jpg'], binmode: true)
    file.write(Base64.decode64('/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjMjMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtREAAgEDAwIEAwUFBAQA AAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExGhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKUlRVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uLj5OXm5+jp6vHy8/T19vf4+fr/2gAMAwEAAhEDEQA/AMWf'))
    file.rewind
    item.photo.attach(io: file, filename: 'test_image.jpg', content_type: 'image/jpeg')
  end
end
