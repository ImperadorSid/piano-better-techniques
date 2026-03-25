class AddAiOverviewToSongAnalyses < ActiveRecord::Migration[8.1]
  def change
    add_column :song_analyses, :ai_overview, :text
    add_column :song_analyses, :ai_song_map, :text
    add_column :song_analyses, :ai_hand_positions, :text
    add_column :song_analyses, :ai_difficult_sections, :text
    add_column :song_analyses, :ai_harmony, :text
  end
end
