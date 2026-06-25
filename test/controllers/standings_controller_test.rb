require "test_helper"

class StandingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get standings_index_url
    assert_response :success
  end

  test "should get classified" do
    get standings_classified_url
    assert_response :success
  end
end
