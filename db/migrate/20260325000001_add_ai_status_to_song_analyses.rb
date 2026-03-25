class AddAIStatusToSongAnalyses < ActiveRecord::Migration[8.1]
  def change
    add_column :song_analyses, :ai_status, :string
  end
end
