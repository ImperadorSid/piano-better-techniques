# db/seeds.rb
# Seeds 3 beginner songs with manually crafted note sequences.
# Safe to re-run (find_or_create_by on title).

puts "Seeding songs..."

# ─── Song 1: Twinkle Twinkle Little Star ────────────────────────────────────
twinkle = Song.find_or_create_by!(title: "Twinkle Twinkle Little Star") do |s|
  s.composer       = "Traditional"
  s.difficulty     = 1
  s.tempo_bpm      = 100
  s.time_signature = "4/4"
  s.key_signature  = "C"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if twinkle.song_parts.empty?
  twinkle_notes = [
    # Phrase 1: Twin-kle twin-kle lit-tle star (C C G G A A G)
    { "pos" => 0,  "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 1.0 },
    { "pos" => 2,  "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 2.0 },
    { "pos" => 3,  "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 3.0 },
    { "pos" => 4,  "midi" => 69, "name" => "A4", "dur" => 1.0, "vel" => 85, "beat" => 4.0 },
    { "pos" => 5,  "midi" => 69, "name" => "A4", "dur" => 1.0, "vel" => 85, "beat" => 5.0 },
    { "pos" => 6,  "midi" => 67, "name" => "G4", "dur" => 2.0, "vel" => 80, "beat" => 6.0 },
    # Phrase 2: How I won-der what you are (F F E E D D C)
    { "pos" => 7,  "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 8.0 },
    { "pos" => 8,  "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 9.0 },
    { "pos" => 9,  "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 10.0 },
    { "pos" => 10, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 11.0 },
    { "pos" => 11, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 75, "beat" => 12.0 },
    { "pos" => 12, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 75, "beat" => 13.0 },
    { "pos" => 13, "midi" => 60, "name" => "C4", "dur" => 2.0, "vel" => 75, "beat" => 14.0 },
    # Phrase 3: Up a-bove the world so high (G G F F E E D)
    { "pos" => 14, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 16.0 },
    { "pos" => 15, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 17.0 },
    { "pos" => 16, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 18.0 },
    { "pos" => 17, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 19.0 },
    { "pos" => 18, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 20.0 },
    { "pos" => 19, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 21.0 },
    { "pos" => 20, "midi" => 62, "name" => "D4", "dur" => 2.0, "vel" => 75, "beat" => 22.0 },
    # Phrase 4: Like a dia-mond in the sky (G G F F E E D)
    { "pos" => 21, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 24.0 },
    { "pos" => 22, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 25.0 },
    { "pos" => 23, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 26.0 },
    { "pos" => 24, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 27.0 },
    { "pos" => 25, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 28.0 },
    { "pos" => 26, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 29.0 },
    { "pos" => 27, "midi" => 62, "name" => "D4", "dur" => 2.0, "vel" => 75, "beat" => 30.0 },
    # Repeat phrase 1
    { "pos" => 28, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 32.0 },
    { "pos" => 29, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 33.0 },
    { "pos" => 30, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 34.0 },
    { "pos" => 31, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 35.0 },
    { "pos" => 32, "midi" => 69, "name" => "A4", "dur" => 1.0, "vel" => 85, "beat" => 36.0 },
    { "pos" => 33, "midi" => 69, "name" => "A4", "dur" => 1.0, "vel" => 85, "beat" => 37.0 },
    { "pos" => 34, "midi" => 67, "name" => "G4", "dur" => 2.0, "vel" => 80, "beat" => 38.0 },
    # Repeat phrase 2
    { "pos" => 35, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 40.0 },
    { "pos" => 36, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 75, "beat" => 41.0 },
    { "pos" => 37, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 42.0 },
    { "pos" => 38, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 75, "beat" => 43.0 },
    { "pos" => 39, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 75, "beat" => 44.0 },
    { "pos" => 40, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 75, "beat" => 45.0 },
    { "pos" => 41, "midi" => 60, "name" => "C4", "dur" => 2.0, "vel" => 80, "beat" => 46.0 }
  ]

  twinkle.song_parts.create!(
    name: "Melody (Right Hand)",
    hand: "right",
    notes_data: twinkle_notes,
    note_count: twinkle_notes.size
  )

  twinkle.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "C",  "quality" => "major" },
      { "beat" => 4,  "chord" => "F",  "quality" => "major" },
      { "beat" => 6,  "chord" => "G",  "quality" => "dominant" },
      { "beat" => 8,  "chord" => "C",  "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 16, "level" => 1, "label" => "Main melody" },
      { "start_beat" => 16, "end_beat" => 32, "level" => 1, "label" => "Main melody" },
      { "start_beat" => 32, "end_beat" => 48, "level" => 1, "label" => "Repeat" }
    ],
    dynamics_map: [
      { "beat" => 0, "velocity_avg" => 80, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Twinkle Twinkle Little Star"

# ─── Song 2: Ode to Joy ──────────────────────────────────────────────────────
ode = Song.find_or_create_by!(title: "Ode to Joy") do |s|
  s.composer       = "Beethoven"
  s.difficulty     = 1
  s.tempo_bpm      = 110
  s.time_signature = "4/4"
  s.key_signature  = "C"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if ode.song_parts.empty?
  ode_notes = [
    # Phrase A (E E F G G F E D C C D E)
    { "pos" => 0,  "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 85, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 1.0 },
    { "pos" => 2,  "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 80, "beat" => 2.0 },
    { "pos" => 3,  "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 85, "beat" => 3.0 },
    { "pos" => 4,  "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 85, "beat" => 4.0 },
    { "pos" => 5,  "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 80, "beat" => 5.0 },
    { "pos" => 6,  "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 6.0 },
    { "pos" => 7,  "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 7.0 },
    { "pos" => 8,  "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 8.0 },
    { "pos" => 9,  "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 9.0 },
    { "pos" => 10, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 10.0 },
    { "pos" => 11, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 11.0 },
    { "pos" => 12, "midi" => 64, "name" => "E4", "dur" => 1.5, "vel" => 85, "beat" => 12.0 },
    { "pos" => 13, "midi" => 62, "name" => "D4", "dur" => 0.5, "vel" => 75, "beat" => 13.5 },
    { "pos" => 14, "midi" => 62, "name" => "D4", "dur" => 2.0, "vel" => 80, "beat" => 14.0 },
    # Phrase B (E E F G G F E D C C D E D C C)
    { "pos" => 15, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 85, "beat" => 16.0 },
    { "pos" => 16, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 17.0 },
    { "pos" => 17, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 80, "beat" => 18.0 },
    { "pos" => 18, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 85, "beat" => 19.0 },
    { "pos" => 19, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 85, "beat" => 20.0 },
    { "pos" => 20, "midi" => 65, "name" => "F4", "dur" => 1.0, "vel" => 80, "beat" => 21.0 },
    { "pos" => 21, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 22.0 },
    { "pos" => 22, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 23.0 },
    { "pos" => 23, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 24.0 },
    { "pos" => 24, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 25.0 },
    { "pos" => 25, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 26.0 },
    { "pos" => 26, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 27.0 },
    { "pos" => 27, "midi" => 62, "name" => "D4", "dur" => 1.5, "vel" => 85, "beat" => 28.0 },
    { "pos" => 28, "midi" => 60, "name" => "C4", "dur" => 0.5, "vel" => 75, "beat" => 29.5 },
    { "pos" => 29, "midi" => 60, "name" => "C4", "dur" => 2.0, "vel" => 80, "beat" => 30.0 }
  ]

  ode.song_parts.create!(
    name: "Melody (Right Hand)",
    hand: "right",
    notes_data: ode_notes,
    note_count: ode_notes.size
  )

  ode.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "C",  "quality" => "major" },
      { "beat" => 4,  "chord" => "G",  "quality" => "dominant" },
      { "beat" => 8,  "chord" => "C",  "quality" => "major" },
      { "beat" => 12, "chord" => "G",  "quality" => "dominant" },
      { "beat" => 16, "chord" => "C",  "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 16, "level" => 1, "label" => "Phrase A" },
      { "start_beat" => 16, "end_beat" => 32, "level" => 2, "label" => "Phrase B" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 82, "marking" => "mf" },
      { "beat" => 16, "velocity_avg" => 85, "marking" => "f" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Ode to Joy"

# ─── Song 3: Mary Had a Little Lamb ─────────────────────────────────────────
mary = Song.find_or_create_by!(title: "Mary Had a Little Lamb") do |s|
  s.composer       = "Traditional"
  s.difficulty     = 1
  s.tempo_bpm      = 100
  s.time_signature = "4/4"
  s.key_signature  = "C"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if mary.song_parts.empty?
  mary_notes = [
    # Verse 1: Ma-ry had a lit-tle lamb (E D C D E E E)
    { "pos" => 0,  "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 1.0 },
    { "pos" => 2,  "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 2.0 },
    { "pos" => 3,  "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 3.0 },
    { "pos" => 4,  "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 85, "beat" => 4.0 },
    { "pos" => 5,  "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 85, "beat" => 5.0 },
    { "pos" => 6,  "midi" => 64, "name" => "E4", "dur" => 2.0, "vel" => 85, "beat" => 6.0 },
    # Lit-tle lamb lit-tle lamb (D D D E G G)
    { "pos" => 7,  "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 8.0 },
    { "pos" => 8,  "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 9.0 },
    { "pos" => 9,  "midi" => 62, "name" => "D4", "dur" => 2.0, "vel" => 80, "beat" => 10.0 },
    { "pos" => 10, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 12.0 },
    { "pos" => 11, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 85, "beat" => 13.0 },
    { "pos" => 12, "midi" => 67, "name" => "G4", "dur" => 2.0, "vel" => 85, "beat" => 14.0 },
    # Ma-ry had a lit-tle lamb (E D C D E E E E)
    { "pos" => 13, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 16.0 },
    { "pos" => 14, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 17.0 },
    { "pos" => 15, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 18.0 },
    { "pos" => 16, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 19.0 },
    { "pos" => 17, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 85, "beat" => 20.0 },
    { "pos" => 18, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 85, "beat" => 21.0 },
    { "pos" => 19, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 85, "beat" => 22.0 },
    { "pos" => 20, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 23.0 },
    # Whose fleece was white as snow (D D E D C)
    { "pos" => 21, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 24.0 },
    { "pos" => 22, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 25.0 },
    { "pos" => 23, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 26.0 },
    { "pos" => 24, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 27.0 },
    { "pos" => 25, "midi" => 60, "name" => "C4", "dur" => 2.0, "vel" => 85, "beat" => 28.0 }
  ]

  mary.song_parts.create!(
    name: "Melody (Right Hand)",
    hand: "right",
    notes_data: mary_notes,
    note_count: mary_notes.size
  )

  mary.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "C", "quality" => "major" },
      { "beat" => 4,  "chord" => "G", "quality" => "dominant" },
      { "beat" => 8,  "chord" => "C", "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 8,  "level" => 1, "label" => "Verse 1" },
      { "start_beat" => 8,  "end_beat" => 16, "level" => 1, "label" => "Verse 2" },
      { "start_beat" => 16, "end_beat" => 30, "level" => 1, "label" => "Verse 3" }
    ],
    dynamics_map: [
      { "beat" => 0, "velocity_avg" => 80, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Mary Had a Little Lamb"
puts "\nSeeded #{Song.count} songs, #{SongPart.count} parts, #{SongAnalysis.count} analyses."
