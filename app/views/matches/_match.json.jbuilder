json.extract! match, :id, :stage, :group_id, :home_team_id, :away_team_id, :home_score, :away_score, :home_penalties, :away_penalties, :winner_team_id, :played, :match_number, :next_match_id, :next_match_slot, :created_at, :updated_at
json.url match_url(match, format: :json)
