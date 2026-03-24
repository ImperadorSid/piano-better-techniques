class CreateSongs < ActiveRecord::Migration[8.1]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :composer
      t.integer :difficulty
      t.integer :tempo_bpm
      t.string :time_signature
      t.string :key_signature
      t.string :source_url
      t.string :source_format
      t.text :raw_source
      t.string :import_status
      t.integer :total_notes

      t.timestamps
    end
  end
end
