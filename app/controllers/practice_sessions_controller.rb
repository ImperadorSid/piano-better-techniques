class PracticeSessionsController < ApplicationController
  before_action :set_song_part, only: [ :create, :show ]
  before_action :set_session, only: [ :show, :complete ]

  def index
    @sessions = PracticeSession.includes(:song, :song_part).order(created_at: :desc)
  end

  def show
  end

  def create
    @session = @song_part.practice_sessions.create!(
      song: @song_part.song,
      started_at: Time.current,
      total_notes: @song_part.note_count
    )
    redirect_to song_part_practice_session_path(@song_part, @session)
  end

  def complete
    @session.complete!(
      notes_reached: params[:notes_reached].to_i,
      correct_notes: params[:correct_notes]&.to_i,
      incorrect_notes: params[:incorrect_notes]&.to_i
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "session_complete",
          partial: "practice_sessions/complete",
          locals: { session: @session }
        )
      end
      format.html { redirect_to practice_sessions_path }
    end
  end

  private

  def set_song_part
    @song_part = SongPart.find(params[:song_part_id])
  end

  def set_session
    @session = PracticeSession.find(params[:id])
    @song_part ||= @session.song_part
  end
end
