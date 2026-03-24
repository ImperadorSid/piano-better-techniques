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
  end

  def import
    if request.post?
      @song = Song.new(title: import_params[:title] || "Imported Song")
      @song.source_url = import_params[:source_url].presence
      @song.source_format = detect_format(import_params)

      if import_params[:file].present?
        @song.raw_source = import_params[:file].read
      end

      if @song.save
        SongImportJob.perform_later(@song.id)
        redirect_to @song, notice: "Import started. The song will be ready shortly."
      else
        render :import, status: :unprocessable_entity
      end
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

  def import_params
    params.permit(:title, :source_url, :file)
  end

  def detect_format(params)
    return "midi" if params[:file]&.content_type&.include?("midi")
    return "abc" if params[:source_url]&.include?("thesession.org")
    "manual"
  end
end
