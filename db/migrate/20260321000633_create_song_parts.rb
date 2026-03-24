class CreateSongParts < ActiveRecord::Migration[8.1]
  def change
    create_table :song_parts do |t|
      t.references :song, null: false, foreign_key: true
      t.string :name
      t.string :hand
      t.json :notes_data
      t.integer :note_count

      t.timestamps
    end
  end
end
