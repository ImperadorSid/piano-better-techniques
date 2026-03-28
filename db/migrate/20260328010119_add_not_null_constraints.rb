class AddNotNullConstraints < ActiveRecord::Migration[8.1]
  def change
    # Songs
    change_column_null :songs, :title, false
    change_column_null :songs, :difficulty, false, 1
    change_column_null :songs, :import_status, false, "pending"

    # Song parts
    change_column_null :song_parts, :name, false
    change_column_null :song_parts, :hand, false

    # Practice sessions
    change_column_null :practice_sessions, :completed, false, false
    change_column_null :practice_sessions, :started_at, false

    # Session attempts
    change_column_null :session_attempts, :note_position, false, 0
    change_column_null :session_attempts, :expected_midi, false, 0
    change_column_null :session_attempts, :played_midi, false, 0

    # Unique index: one analysis per song
    add_index :song_analyses, :song_id, unique: true, name: "index_song_analyses_on_song_id_unique"
  end
end
