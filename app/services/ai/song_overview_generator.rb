module AI
  # Calls the Claude API to generate a structured, beginner-friendly analysis of a song.
  # Uses tool_use (structured output) to guarantee valid JSON conforming to the expected schema.
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

      attrs = {
        ai_overview:           parsed["overview"].to_json,
        ai_song_map:           parsed["song_map"].to_json,
        ai_hand_positions:     parsed["hand_positions"].to_json,
        ai_difficult_sections: parsed["difficult_sections"].to_json,
        ai_harmony:            parsed["harmony"].to_json,
        ai_status:             nil
      }

      usage = response.body["usage"]
      if usage
        attrs[:input_tokens] = usage["input_tokens"]
        attrs[:output_tokens] = usage["output_tokens"]
      end

      analysis.update!(attrs)
    end

    private

    def api_key
      ENV["ANTHROPIC_API_KEY"]
    end

    def build_payload
      {
        model: MODEL,
        max_tokens: 4096,
        tools: [ tool_definition ],
        tool_choice: { type: "tool", name: "song_analysis" },
        messages: [
          { role: "user", content: prompt }
        ]
      }
    end

    def tool_definition
      {
        name: "song_analysis",
        description: "Store a structured, beginner-friendly analysis of a piano song.",
        input_schema: {
          type: "object",
          required: %w[overview song_map hand_positions difficult_sections harmony],
          properties: {
            overview: {
              type: "object",
              required: %w[mood key_insight tempo_insight time_insight estimated_practice_time key_takeaway body],
              properties: {
                mood: { type: "string", description: "One sentence describing the emotional character" },
                key_insight: { type: "string", description: "What the key signature means practically" },
                tempo_insight: { type: "string", description: "The tempo in relatable terms" },
                time_insight: { type: "string", description: "The time signature explained simply" },
                estimated_practice_time: { type: "string", description: "e.g. '2-3 hours'" },
                key_takeaway: { type: "string", description: "The single most important thing for a beginner" },
                body: { type: "string", description: "2 concise paragraphs about character and practical guidance" }
              }
            },
            song_map: {
              type: "array",
              items: {
                type: "object",
                required: %w[section beats chords description],
                properties: {
                  section: { type: "string" },
                  beats: { type: "string" },
                  chords: { type: "string" },
                  description: { type: "string" }
                }
              }
            },
            hand_positions: {
              type: "object",
              required: %w[right left coordination_tip],
              properties: {
                right: {
                  type: "object",
                  required: %w[position role drill target_bpm],
                  properties: {
                    position: { type: "string" },
                    role: { type: "string" },
                    drill: { type: "string" },
                    target_bpm: { type: "integer" }
                  }
                },
                left: {
                  type: "object",
                  required: %w[position role drill target_bpm],
                  properties: {
                    position: { type: "string" },
                    role: { type: "string" },
                    drill: { type: "string" },
                    target_bpm: { type: "integer" }
                  }
                },
                coordination_tip: { type: "string" }
              }
            },
            difficult_sections: {
              type: "array",
              items: {
                type: "object",
                required: %w[name beats challenge method start_bpm milestone],
                properties: {
                  name: { type: "string" },
                  beats: { type: "string" },
                  challenge: { type: "string" },
                  method: { type: "string" },
                  start_bpm: { type: "integer" },
                  milestone: { type: "string" }
                }
              }
            },
            harmony: {
              type: "object",
              required: %w[chord_emotions dynamics_guidance],
              properties: {
                chord_emotions: {
                  type: "array",
                  items: {
                    type: "object",
                    required: %w[chord emotion],
                    properties: {
                      chord: { type: "string" },
                      emotion: { type: "string" }
                    }
                  }
                },
                dynamics_guidance: { type: "string" }
              }
            }
          }
        }
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

        Use the song_analysis tool to store your response. Provide at least 2 difficult sections and one song map entry per distinct section.
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

      tool_block = response.body.dig("content")&.find { |b| b["type"] == "tool_use" }
      return nil unless tool_block

      tool_block["input"]
    rescue StandardError => e
      Rails.logger.error("[AI::SongOverviewGenerator] Failed to parse Claude response: #{e.message}")
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
