class CreateSongAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :song_analyses do |t|
      t.references :song, null: false, foreign_key: true
      t.json :chord_progressions
      t.json :difficulty_sections
      t.json :dynamics_map
      t.json :hand_separation

      t.timestamps
    end
  end
end
