module AI
  # Calls the Claude API to generate a structured, beginner-friendly analysis of a song.
  # Returns structured JSON stored in the five ai_* text fields on SongAnalysis.
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
        ai_overview:           parsed["overview"].to_json,
        ai_song_map:           parsed["song_map"].to_json,
        ai_hand_positions:     parsed["hand_positions"].to_json,
        ai_difficult_sections: parsed["difficult_sections"].to_json,
        ai_harmony:            parsed["harmony"].to_json,
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
        max_tokens: 4096,
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
        You are a professional music teacher and piano coach. Given the following song data, generate a structured analysis to help a beginner understand and practice this piece efficiently.

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

        Write in a warm, confident, encouraging tone — like a patient teacher. Address the student as "you". Use plain language: avoid jargon, explain musical terms simply. Give concrete advice (exact fingers, BPM numbers, drill names).

        Respond with ONLY a valid JSON object (no markdown, no extra text, no code fences) with exactly these five keys. Each value must be a structured JSON object or array, NOT plain text strings:

        {
          "overview": {
            "mood": "One sentence describing the emotional character and feel of this piece",
            "key_insight": "One sentence explaining what the key signature means practically (e.g. which keys to use)",
            "tempo_insight": "One sentence explaining the tempo in relatable terms (e.g. 'a comfortable walking pace')",
            "time_insight": "One sentence explaining the time signature (e.g. 'count 1-2-3-4 steadily')",
            "estimated_practice_time": "Estimated hours to learn this piece (e.g. '2-3 hours')",
            "key_takeaway": "The single most important thing for a beginner to know about this piece",
            "body": "2 concise paragraphs: first about the song's emotional character and what makes it satisfying, second about practical key/tempo/time signature guidance."
          },
          "song_map": [
            {"section": "Letter or name", "beats": "start-end", "chords": "Chord names used", "description": "One sentence describing what happens musically"},
            ...repeat for each distinct section
          ],
          "hand_positions": {
            "right": {"position": "Note range (e.g. C4-G4)", "role": "What this hand plays (e.g. Melody)", "drill": "Named practice drill", "target_bpm": integer},
            "left": {"position": "Note range (e.g. C3-G3)", "role": "What this hand plays (e.g. Bass notes)", "drill": "Named practice drill", "target_bpm": integer},
            "coordination_tip": "One sentence on how to bring both hands together"
          },
          "difficult_sections": [
            {"name": "Section name or description", "beats": "start-end", "challenge": "What makes it hard in plain words", "method": "Named practice method", "start_bpm": integer, "milestone": "Clear goal to hit before moving on"},
            ...repeat for each challenging section (at least 2)
          ],
          "harmony": {
            "chord_emotions": [
              {"chord": "Chord name", "emotion": "2-4 word feel (e.g. 'home and settled', 'gentle warmth', 'rising tension')"},
              ...repeat for each chord in the progression
            ],
            "dynamics_guidance": "2-3 sentences about when to play softer/louder and why the contrast matters"
          }
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
        req.headers["anthropic-version"] = "2024-10-22"
        req.headers["content-type"] = "application/json"
        req.options.timeout = 60
        req.options.open_timeout = 10
        req.body = payload
      end
    end

    def parse_response(response)
      return nil unless response.success?

      log_token_usage(response)

      content = response.body.dig("content", 0, "text")
      return nil if content.blank?

      JSON.parse(content)
    rescue JSON::ParserError => e
      Rails.logger.error("[AI::SongOverviewGenerator] Failed to parse Claude response: #{e.message} — content length: #{content.length}, last 100 chars: #{content.last(100)}")
      nil
    end

    def log_token_usage(response)
      usage = response.body["usage"]
      return unless usage

      Rails.logger.info(
        "[AI::SongOverviewGenerator] Token usage for song #{@song.id}: " \
        "input=#{usage["input_tokens"]}, output=#{usage["output_tokens"]}"
      )
    end
  end
end
