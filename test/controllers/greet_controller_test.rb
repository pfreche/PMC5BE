require 'test_helper'

class GreetControllerTest < ActionDispatch::IntegrationTest
  test "should get hi" do
    get greet_hi_url
    assert_response :success
  end

end
