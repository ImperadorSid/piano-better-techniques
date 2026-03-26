class AddVelocityToSessionAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :session_attempts, :played_velocity, :integer
    add_column :session_attempts, :expected_velocity, :integer
  end
end
