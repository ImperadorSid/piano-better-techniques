module AI
  # Calls the Claude API to generate a beginner-friendly overview of a song.
  # Populates the five ai_* text fields on the song's SongAnalysis record.
  # Skips silently if ANTHROPIC_API_KEY is not set.
  class SongOverviewGenerator
    ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
    MODEL = "claude-sonnet-4-6"

    def initialize(song)
      @song = song
    end

    def generate!
      return unless api_key.present?

      analysis = @song.song_analysis
      return unless analysis

      payload = build_payload
      response = call_api(payload)
      parsed = parse_response(response)
      return unless parsed

      analysis.update!(
        ai_overview:           parsed["overview"],
        ai_song_map:           parsed["song_map"],
        ai_hand_positions:     parsed["hand_positions"],
        ai_difficult_sections: parsed["difficult_sections"],
        ai_harmony:            parsed["harmony"],
        ai_status:             nil
      )
    end

    private

    def api_key
      ENV["ANTHROPIC_API_KEY"]
    end

    def build_payload
      {
        model: MODEL,
        max_tokens: 2048,
        messages: [
          { role: "user", content: prompt }
        ]
      }
    end

    def prompt
      analysis = @song.song_analysis

      chords = analysis.chord_progressions.map { |c| "Beat #{c["beat"]}: #{c["chord"]} (#{c["quality"]})" }.join(", ")
      sections = analysis.difficulty_sections.map { |s| "#{s["label"]} (beats #{s["start_beat"]}–#{s["end_beat"]}, level #{s["level"]}/5)" }.join("; ")
      dynamics = analysis.dynamics_map.map { |d| "Beat #{d["beat"]}: #{d["marking"]} (vel #{d["velocity_avg"]})" }.join(", ")

      <<~PROMPT
        You are a music teacher helping beginners learn piano. Given the following song data, generate a structured overview to help a beginner understand and practice this piece.

        Song: #{@song.title}
        Composer: #{@song.composer.presence || "Unknown"}
        Key: #{@song.key_signature}
        Tempo: #{@song.tempo_bpm} BPM
        Time Signature: #{@song.time_signature}
        Difficulty: #{@song.difficulty}/5

        Chord Progressions: #{chords.presence || "No chord data"}
        Difficulty Sections: #{sections.presence || "No section data"}
        Dynamics: #{dynamics.presence || "No dynamics data"}
        Hand split point: MIDI note #{analysis.hand_separation["split_midi"].presence || "N/A"}

        Write in a warm, direct, encouraging tone — like a patient teacher sitting next to the student. Address the student as "you". Use plain everyday language: avoid music jargon, and when you must use a musical term, explain it immediately in simple words. Give concrete, specific advice (exact fingers, exact BPM numbers, names for practice drills). Acknowledge where things feel hard and explain why, then give a clear way through it.

        Respond with ONLY a valid JSON object (no markdown, no extra text) with exactly these five keys:

        {
          "overview": "2 paragraphs. First: introduce the song's emotional character and mood — what it feels like to play and what makes it satisfying for a beginner. Second: explain the key and tempo in practical terms (e.g. 'the key of C major means you will be working mostly with the white keys') and what the time signature means for how you count while playing.",
          "song_map": "2 paragraphs acting as a roadmap through the song. First: walk through the chord sections in order — name each section, describe which chords appear and whether they repeat, and tell the student what to expect moment to moment. Second: point out the single biggest structural thing to notice (e.g. a repeating pattern, a turnaround, a section that comes back) and explain why recognising it makes the whole song easier to remember and play.",
          "hand_positions": "2 paragraphs. First: describe exactly where the left hand sits on the keyboard, what it plays (e.g. bass notes, chords, arpeggios), and give one named practice drill to build that hand's independence — include a target BPM and a clear goal. Second: do the same for the right hand — where it sits, what it plays, and one named practice drill. End with one sentence about the key coordination tip for bringing the two hands together.",
          "difficult_sections": "2 paragraphs, each covering one hard section from the difficulty data. For each: name the section and describe in plain words exactly what makes it tricky (e.g. 'your fingers need to jump quickly from one position to another'). Then give a specific, named practice method with a concrete starting BPM and a clear milestone to hit before moving on.",
          "harmony": "2 paragraphs. First: explain what each chord in the progression is doing emotionally — describe each one in one short phrase (e.g. 'home and settled', 'a little uncertain', 'the emotional peak') so the student understands the story the chords are telling. Second: give practical dynamics guidance tied to the song's sections — describe when to play softer and when to play louder, and explain in plain terms why that contrast makes the music come alive."
        }
      PROMPT
    end

    def call_api(payload)
      conn = Faraday.new(url: ANTHROPIC_API_URL) do |f|
        f.request :json
        f.response :json
        f.request :retry, max: 2, interval: 1
        f.adapter Faraday.default_adapter
      end

      conn.post do |req|
        req.headers["x-api-key"] = api_key
        req.headers["anthropic-version"] = "2023-06-01"
        req.headers["content-type"] = "application/json"
        req.body = payload
      end
    end

    def parse_response(response)
      return nil unless response.success?

      content = response.body.dig("content", 0, "text")
      return nil if content.blank?

      JSON.parse(content)
    rescue JSON::ParserError
      Rails.logger.error("[AI::SongOverviewGenerator] Failed to parse Claude response: #{content.truncate(200)}")
      nil
    end
  end
end
