# test/models/user_test.rb

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Test if the user model is valid with valid attributes
  test "should be valid with valid attributes" do
    user = User.new(email: 'test@example.com', password: 'password')
    assert user.valid?
  end

  # Test if the user model is invalid without an email
  test "should be invalid without an email" do
    user = User.new(password: 'password')
    refute user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  # Test if the user model is invalid without a password
  test "should be invalid without a password" do
    user = User.new(email: 'test@example.com')
    refute user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end
end
