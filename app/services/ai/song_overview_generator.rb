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
        ai_harmony:            parsed["harmony"]
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

        Respond with ONLY a valid JSON object (no markdown, no extra text) with exactly these five keys:

        {
          "overview": "2 paragraphs introducing the song to a beginner: what the song feels like and its general mood, and a simple note about the speed and how many beats are in each measure.",
          "song_map": "2 paragraphs describing the chord sections in order. Keep it simple: mention which chords repeat, where the song changes, and what to expect when playing through it.",
          "hand_positions": "2 paragraphs: one for the left hand and one for the right hand. Describe where each hand sits on the keyboard and what it plays, using simple everyday language.",
          "difficult_sections": "2 paragraphs covering the hardest parts of the song. Describe what makes each part tricky in plain terms (e.g., moving fingers quickly, reaching far keys) and give one simple practice tip for each.",
          "harmony": "2 paragraphs explaining how the chords sound together and what feeling they create. Mention when to play louder or softer and why it makes the song more expressive."
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
