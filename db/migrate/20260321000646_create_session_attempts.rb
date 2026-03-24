class CreateSessionAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :session_attempts do |t|
      t.references :practice_session, null: false, foreign_key: true
      t.integer :note_position
      t.integer :expected_midi
      t.integer :played_midi
      t.boolean :correct
      t.integer :response_ms

      t.timestamps
    end
  end
end
