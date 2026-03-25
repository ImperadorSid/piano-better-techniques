class SongsController < ApplicationController
  before_action :set_song, only: [ :show, :analyze, :destroy ]

  def index
    @songs = Song.ready.by_difficulty.includes(:song_parts)
  end

  def show
    @song_parts = @song.song_parts
    @song_analysis = @song.song_analysis
  end

  def analyze
    @song_analysis = @song.song_analysis
    if @song_analysis && !@song_analysis.ai_generated?
      AI::SongOverviewGenerator.new(@song).generate!
      @song_analysis.reload
    end
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
