require 'test_helper'

class SearchFeatureTest < ActiveSupport::TestCase
  def setup
    @owner = User.create!(email: 'owner@example.com', password: 'password')

    @item1 = create_and_attach_item(
      name: "Tent",
      category: "Camping",
      description: "A great tent for camping.",
      address: "London",
      price: 1,
      quantity: 10
    )

    @item2 = create_and_attach_item(
      name: "Tent Cover",
      category: "Camping",
      description: "A cover for your tent.",
      address: "Paris",
      price: 9,
      quantity: 5
    )

    @item3 = create_and_attach_item(
      name: "T-shirt",
      category: "Clothing",
      description: "A comfortable t-shirt.",
      address: "Berlin",
      price: 0,
      quantity: 15
    )

    @item4 = create_and_attach_item(
      name: "Lantern",
      category: "Camping",
      description: "A bright lantern for camping.",
      address: "London",
      price: 10,
      quantity: 8
    )
  end

  def create_and_attach_item(attributes)
    item = Item.new(attributes.merge(user: @owner))
    attach_mock_photo(item)
    item.save!
    item
  end

  def attach_mock_photo(item)
    file = Tempfile.new(['test_image', '.jpg'], binmode: true)
    file.write(Base64.decode64('/9j/4AAQSkZJRgABAQEAAAAAAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtREAAgEDAwIEAwUFBAQA AAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExGhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKUlRVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uLj5OXm5+jp6vHy8/T19vf4+fr/2gAMAwEAAhEDEQA/AMWf'))
    file.rewind
    item.photo.attach(io: file, filename: 'test_image.jpg', content_type: 'image/jpeg')
  end

  test "search with invalid query" do
    search_service = SearchFeature.new("InvalidQuery")
    results = search_service.perform

    assert_empty results, "No items should be returned when an invalid query is provided."
  end
end
