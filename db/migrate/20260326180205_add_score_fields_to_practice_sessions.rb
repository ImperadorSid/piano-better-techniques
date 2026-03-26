class AddScoreFieldsToPracticeSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :practice_sessions, :timing_score, :float
    add_column :practice_sessions, :streak_score, :float
    add_column :practice_sessions, :velocity_score, :float
    add_column :practice_sessions, :composite_score, :float
    add_column :practice_sessions, :longest_streak, :integer, default: 0
  end
end
