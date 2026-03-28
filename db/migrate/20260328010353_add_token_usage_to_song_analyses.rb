class AddTokenUsageToSongAnalyses < ActiveRecord::Migration[8.1]
  def change
    add_column :song_analyses, :input_tokens, :integer
    add_column :song_analyses, :output_tokens, :integer
  end
end
