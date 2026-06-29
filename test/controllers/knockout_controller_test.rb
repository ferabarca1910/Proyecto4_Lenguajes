require "test_helper"

class KnockoutControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get knockout_index_url
    assert_response :success
  end

  test "should get podium" do
    get knockout_podium_url
    assert_response :success
  end
end
