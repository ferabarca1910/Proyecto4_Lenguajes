class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :country_name
      t.references :group, null: false, foreign_key: true
      t.integer :points, default: 0
      t.integer :goals_for, default: 0
      t.integer :goals_against, default: 0
      t.integer :goal_difference, default: 0

      t.timestamps
    end
  end
end