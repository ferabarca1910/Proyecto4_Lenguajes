require "application_system_test_case"

class MatchesTest < ApplicationSystemTestCase
  setup do
    @match = matches(:one)
  end

  test "visiting the index" do
    visit matches_url
    assert_selector "h1", text: "Matches"
  end

  test "should create match" do
    visit matches_url
    click_on "New match"

    fill_in "Away penalties", with: @match.away_penalties
    fill_in "Away score", with: @match.away_score
    fill_in "Away team", with: @match.away_team_id
    fill_in "Group", with: @match.group_id
    fill_in "Home penalties", with: @match.home_penalties
    fill_in "Home score", with: @match.home_score
    fill_in "Home team", with: @match.home_team_id
    fill_in "Match number", with: @match.match_number
    fill_in "Next match", with: @match.next_match_id
    fill_in "Next match slot", with: @match.next_match_slot
    check "Played" if @match.played
    fill_in "Stage", with: @match.stage
    fill_in "Winner team", with: @match.winner_team_id
    click_on "Create Match"

    assert_text "Match was successfully created"
    click_on "Back"
  end

  test "should update Match" do
    visit match_url(@match)
    click_on "Edit this match", match: :first

    fill_in "Away penalties", with: @match.away_penalties
    fill_in "Away score", with: @match.away_score
    fill_in "Away team", with: @match.away_team_id
    fill_in "Group", with: @match.group_id
    fill_in "Home penalties", with: @match.home_penalties
    fill_in "Home score", with: @match.home_score
    fill_in "Home team", with: @match.home_team_id
    fill_in "Match number", with: @match.match_number
    fill_in "Next match", with: @match.next_match_id
    fill_in "Next match slot", with: @match.next_match_slot
    check "Played" if @match.played
    fill_in "Stage", with: @match.stage
    fill_in "Winner team", with: @match.winner_team_id
    click_on "Update Match"

    assert_text "Match was successfully updated"
    click_on "Back"
  end

  test "should destroy Match" do
    visit match_url(@match)
    click_on "Destroy this match", match: :first

    assert_text "Match was successfully destroyed"
  end
end
