module Scoring
  class SessionScorer
    WEIGHTS = {
      accuracy: 0.50,
      timing:   0.25,
      velocity: 0.25
    }.freeze

    def initialize(practice_session)
      @session = practice_session
      @attempts = practice_session.session_attempts.order(:note_position)
    end

    def calculate!
      acc = accuracy_score
      tim = timing_score
      vel = velocity_score

      composite = compute_composite(acc, tim, vel)

      @session.update!(
        timing_score:    tim&.round(1),
        velocity_score:  vel&.round(1),
        composite_score: composite&.round(1)
      )
    end

    private

    def accuracy_score
      @session.accuracy_pct.to_f
    end

    def timing_score
      times = @attempts.select(&:correct).filter_map(&:response_ms)
      return 100.0 if times.size < 2

      med = median(times)
      return 100.0 if med == 0

      deviations = times.map { |t| (t - med).abs }
      mad = median(deviations)
      relative_spread = mad.to_f / med

      [0.0, 100.0 - (relative_spread * 200.0)].max
    end

    def velocity_score
      pairs = @attempts.select(&:correct).select { |a|
        a.played_velocity.present? && a.expected_velocity.present?
      }
      return nil if pairs.empty?

      per_note_scores = pairs.map { |a|
        deviation = (a.played_velocity - a.expected_velocity).abs
        [0.0, 100.0 - (deviation.to_f / 127.0 * 200.0)].max
      }

      per_note_scores.sum / per_note_scores.size
    end

    def compute_composite(accuracy, timing, velocity)
      weights = WEIGHTS.dup

      if velocity.nil?
        redistribution = weights[:velocity] / 2.0
        weights.delete(:velocity)
        weights.each_key { |k| weights[k] += redistribution }
      end

      scores = { accuracy: accuracy, timing: timing, velocity: velocity }.compact
      weights.sum { |dimension, weight| (scores[dimension] || 0.0) * weight }
    end

    def median(sorted_values)
      values = sorted_values.sort
      mid = values.size / 2
      if values.size.odd?
        values[mid]
      else
        (values[mid - 1] + values[mid]) / 2.0
      end
    end
  end
end
