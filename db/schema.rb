# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_28_010353) do
  create_table "practice_sessions", force: :cascade do |t|
    t.float "accuracy_pct"
    t.boolean "completed", null: false
    t.float "composite_score"
    t.integer "correct_notes"
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.integer "incorrect_notes"
    t.integer "notes_reached"
    t.integer "song_id", null: false
    t.integer "song_part_id", null: false
    t.datetime "started_at", null: false
    t.float "timing_score"
    t.integer "total_notes"
    t.datetime "updated_at", null: false
    t.float "velocity_score"
    t.index ["song_id"], name: "index_practice_sessions_on_song_id"
    t.index ["song_part_id"], name: "index_practice_sessions_on_song_part_id"
  end

  create_table "session_attempts", force: :cascade do |t|
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.integer "expected_midi", null: false
    t.integer "expected_velocity"
    t.integer "note_position", null: false
    t.integer "played_midi", null: false
    t.integer "played_velocity"
    t.integer "practice_session_id", null: false
    t.integer "response_ms"
    t.datetime "updated_at", null: false
    t.index ["practice_session_id"], name: "index_session_attempts_on_practice_session_id"
  end

  create_table "song_analyses", force: :cascade do |t|
    t.text "ai_difficult_sections"
    t.text "ai_hand_positions"
    t.text "ai_harmony"
    t.text "ai_overview"
    t.text "ai_song_map"
    t.string "ai_status"
    t.json "chord_progressions"
    t.datetime "created_at", null: false
    t.json "difficulty_sections"
    t.json "dynamics_map"
    t.json "hand_separation"
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.integer "song_id", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_song_analyses_on_song_id"
    t.index ["song_id"], name: "index_song_analyses_on_song_id_unique", unique: true
  end

  create_table "song_parts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hand", null: false
    t.string "name", null: false
    t.integer "note_count"
    t.json "notes_data"
    t.integer "song_id", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_song_parts_on_song_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "composer"
    t.datetime "created_at", null: false
    t.integer "difficulty", null: false
    t.string "import_status", null: false
    t.string "key_signature"
    t.text "raw_source"
    t.string "source_format"
    t.string "source_url"
    t.integer "tempo_bpm"
    t.string "time_signature"
    t.string "title", null: false
    t.integer "total_notes"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "practice_sessions", "song_parts"
  add_foreign_key "practice_sessions", "songs"
  add_foreign_key "session_attempts", "practice_sessions"
  add_foreign_key "song_analyses", "songs"
  add_foreign_key "song_parts", "songs"
end
