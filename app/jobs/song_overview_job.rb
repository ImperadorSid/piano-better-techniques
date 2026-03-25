class SongOverviewJob < ApplicationJob
  queue_as :default

  def perform(song_id)
    song = Song.find_by(id: song_id)
    return unless song

    analysis = song.song_analysis
    return unless analysis

    AI::SongOverviewGenerator.new(song).generate!
    analysis.reload

    analysis.update!(ai_status: "failed") unless analysis.ai_generated?
    broadcast(song, analysis)
  rescue => e
    Rails.logger.error("[SongOverviewJob] Failed for song #{song_id}: #{e.message}")
    analysis = song&.song_analysis
    analysis&.update!(ai_status: "failed")
    broadcast(song, analysis) if song && analysis
  end

  private

  def broadcast(song, analysis)
    Turbo::StreamsChannel.broadcast_replace_to(
      "song_overview_#{song.id}",
      target: "ai_overview",
      partial: "songs/ai_overview",
      locals: { song_analysis: analysis }
    )
  end
end
