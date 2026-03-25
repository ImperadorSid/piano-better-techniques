class SongsController < ApplicationController
  before_action :set_song, only: [ :show, :analyze, :regenerate, :destroy ]

  def index
    @songs = Song.ready.by_difficulty.includes(:song_parts)
  end

  def show
    @song_parts = @song.song_parts
    @song_analysis = @song.song_analysis
  end

  def analyze
    @song_analysis = @song.song_analysis
    if @song_analysis && !@song_analysis.ai_generated? && !@song_analysis.ai_pending? && !@song_analysis.ai_failed?
      @song_analysis.update!(ai_status: "pending")
      SongOverviewJob.perform_later(@song.id)
    end
  end

  def regenerate
    @song_analysis = @song.song_analysis
    if @song_analysis && !@song_analysis.ai_pending?
      @song_analysis.update!(
        ai_status: "pending",
        ai_overview: nil,
        ai_song_map: nil,
        ai_hand_positions: nil,
        ai_difficult_sections: nil,
        ai_harmony: nil
      )
      SongOverviewJob.perform_later(@song.id)
    end
    redirect_to analyze_song_path(@song)
  end

  def destroy
    @song.destroy
    redirect_to songs_path, notice: "Song deleted."
  end

  private

  def set_song
    @song = Song.find(params[:id])
  end

end
