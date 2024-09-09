require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: 'testuser@example.com', password: 'password')
    sign_in @user
  end

  test "should get index" do
    get dashboard_path # Update to the correct path helper
    assert_response :success
  end
end
