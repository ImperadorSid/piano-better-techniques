class DashboardController < ApplicationController
  def index
    @recent_sessions = PracticeSession.includes(:song, :song_part)
                                      .where(completed: true)
                                      .order(created_at: :desc)
                                      .limit(20)

    @total_sessions = PracticeSession.where(completed: true).count
    @avg_accuracy = PracticeSession.where(completed: true).average(:accuracy_pct)&.round(1) || 0
    @avg_score = PracticeSession.where(completed: true).where.not(composite_score: nil).average(:composite_score)&.round(1) || 0
    @songs_practiced = PracticeSession.where(completed: true).distinct.count(:song_id)

    @accuracy_chart_data = @recent_sessions.reverse.map do |s|
      { date: s.created_at.strftime("%b %d"), accuracy: s.accuracy_pct.to_f }
    end
  end
end
