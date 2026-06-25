class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.string :stage
      t.integer :group_id
      t.integer :home_team_id
      t.integer :away_team_id
      t.integer :home_score
      t.integer :away_score
      t.integer :home_penalties
      t.integer :away_penalties
      t.integer :winner_team_id
      t.boolean :played, default: false
      t.integer :match_number
      t.integer :next_match_id
      t.string :next_match_slot

      t.timestamps
    end
  end
end
