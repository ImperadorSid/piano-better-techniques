class RemoveStreakFieldsFromPracticeSessions < ActiveRecord::Migration[8.1]
  def change
    remove_column :practice_sessions, :streak_score, :float
    remove_column :practice_sessions, :longest_streak, :integer, default: 0
  end
end
