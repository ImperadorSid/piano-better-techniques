class AttemptsController < ApplicationController
  skip_forgery_protection # CSRF handled via JSON content-type + same-origin

  def create
    session = PracticeSession.find(params[:practice_session_id])
    p = attempt_params

    session.record_attempt!(
      note_position: p[:note_position].to_i,
      expected_midi: p[:expected_midi].to_i,
      played_midi: p[:played_midi].to_i,
      correct: ActiveModel::Type::Boolean.new.cast(p[:correct]),
      response_ms: p[:response_ms]&.to_i,
      played_velocity: p[:played_velocity]&.to_i,
      expected_velocity: p[:expected_velocity]&.to_i
    )

    render json: { ok: true }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Session not found" }, status: :not_found
  end

  private

  def attempt_params
    params.require(:attempt).permit(:note_position, :expected_midi, :played_midi, :correct, :response_ms, :played_velocity, :expected_velocity)
  end
end
