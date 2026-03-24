class CreatePracticeSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :practice_sessions do |t|
      t.references :song, null: false, foreign_key: true
      t.references :song_part, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :total_notes
      t.integer :correct_notes
      t.integer :incorrect_notes
      t.float :accuracy_pct
      t.integer :notes_reached
      t.boolean :completed

      t.timestamps
    end
  end
end
