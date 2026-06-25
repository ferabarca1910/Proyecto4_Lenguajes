require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @match = matches(:one)
  end

  test "should get index" do
    get matches_url
    assert_response :success
  end

  test "should get new" do
    get new_match_url
    assert_response :success
  end

  test "should create match" do
    assert_difference("Match.count") do
      post matches_url, params: { match: { away_penalties: @match.away_penalties, away_score: @match.away_score, away_team_id: @match.away_team_id, group_id: @match.group_id, home_penalties: @match.home_penalties, home_score: @match.home_score, home_team_id: @match.home_team_id, match_number: @match.match_number, next_match_id: @match.next_match_id, next_match_slot: @match.next_match_slot, played: @match.played, stage: @match.stage, winner_team_id: @match.winner_team_id } }
    end

    assert_redirected_to match_url(Match.last)
  end

  test "should show match" do
    get match_url(@match)
    assert_response :success
  end

  test "should get edit" do
    get edit_match_url(@match)
    assert_response :success
  end

  test "should update match" do
    patch match_url(@match), params: { match: { away_penalties: @match.away_penalties, away_score: @match.away_score, away_team_id: @match.away_team_id, group_id: @match.group_id, home_penalties: @match.home_penalties, home_score: @match.home_score, home_team_id: @match.home_team_id, match_number: @match.match_number, next_match_id: @match.next_match_id, next_match_slot: @match.next_match_slot, played: @match.played, stage: @match.stage, winner_team_id: @match.winner_team_id } }
    assert_redirected_to match_url(@match)
  end

  test "should destroy match" do
    assert_difference("Match.count", -1) do
      delete match_url(@match)
    end

    assert_redirected_to matches_url
  end
end
