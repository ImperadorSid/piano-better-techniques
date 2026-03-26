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

# ─── Song 4: Happy Birthday ───────────────────────────────────────────────────
happy = Song.find_or_create_by!(title: "Happy Birthday") do |s|
  s.composer       = "Traditional"
  s.difficulty     = 1
  s.tempo_bpm      = 100
  s.time_signature = "3/4"
  s.key_signature  = "C"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if happy.song_parts.empty?
  happy_notes = [
    # Hap-py birth-day to you (G G A G C B)
    { "pos" => 0,  "midi" => 67, "name" => "G4", "dur" => 0.75, "vel" => 75, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 67, "name" => "G4", "dur" => 0.25, "vel" => 75, "beat" => 0.75 },
    { "pos" => 2,  "midi" => 69, "name" => "A4", "dur" => 1.0,  "vel" => 80, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 67, "name" => "G4", "dur" => 1.0,  "vel" => 80, "beat" => 2.0 },
    { "pos" => 4,  "midi" => 72, "name" => "C5", "dur" => 1.0,  "vel" => 85, "beat" => 3.0 },
    { "pos" => 5,  "midi" => 71, "name" => "B4", "dur" => 2.0,  "vel" => 80, "beat" => 4.0 },
    # Hap-py birth-day to you (G G A G D C)
    { "pos" => 6,  "midi" => 67, "name" => "G4", "dur" => 0.75, "vel" => 75, "beat" => 6.0 },
    { "pos" => 7,  "midi" => 67, "name" => "G4", "dur" => 0.25, "vel" => 75, "beat" => 6.75 },
    { "pos" => 8,  "midi" => 69, "name" => "A4", "dur" => 1.0,  "vel" => 80, "beat" => 7.0 },
    { "pos" => 9,  "midi" => 67, "name" => "G4", "dur" => 1.0,  "vel" => 80, "beat" => 8.0 },
    { "pos" => 10, "midi" => 74, "name" => "D5", "dur" => 1.0,  "vel" => 85, "beat" => 9.0 },
    { "pos" => 11, "midi" => 72, "name" => "C5", "dur" => 2.0,  "vel" => 80, "beat" => 10.0 },
    # Hap-py birth-day dear friend (G G G5 E C B A)
    { "pos" => 12, "midi" => 67, "name" => "G4", "dur" => 0.75, "vel" => 75, "beat" => 12.0 },
    { "pos" => 13, "midi" => 67, "name" => "G4", "dur" => 0.25, "vel" => 75, "beat" => 12.75 },
    { "pos" => 14, "midi" => 79, "name" => "G5", "dur" => 1.0,  "vel" => 90, "beat" => 13.0 },
    { "pos" => 15, "midi" => 76, "name" => "E5", "dur" => 1.0,  "vel" => 85, "beat" => 14.0 },
    { "pos" => 16, "midi" => 72, "name" => "C5", "dur" => 1.0,  "vel" => 80, "beat" => 15.0 },
    { "pos" => 17, "midi" => 71, "name" => "B4", "dur" => 1.0,  "vel" => 80, "beat" => 16.0 },
    { "pos" => 18, "midi" => 69, "name" => "A4", "dur" => 1.0,  "vel" => 80, "beat" => 17.0 },
    # Hap-py birth-day to you (F F E C D C)
    { "pos" => 19, "midi" => 77, "name" => "F5", "dur" => 0.75, "vel" => 80, "beat" => 18.0 },
    { "pos" => 20, "midi" => 77, "name" => "F5", "dur" => 0.25, "vel" => 80, "beat" => 18.75 },
    { "pos" => 21, "midi" => 76, "name" => "E5", "dur" => 1.0,  "vel" => 85, "beat" => 19.0 },
    { "pos" => 22, "midi" => 72, "name" => "C5", "dur" => 1.0,  "vel" => 80, "beat" => 20.0 },
    { "pos" => 23, "midi" => 74, "name" => "D5", "dur" => 1.0,  "vel" => 85, "beat" => 21.0 },
    { "pos" => 24, "midi" => 72, "name" => "C5", "dur" => 2.0,  "vel" => 85, "beat" => 22.0 }
  ]

  happy.song_parts.create!(
    name: "Melody (Right Hand)",
    hand: "right",
    notes_data: happy_notes,
    note_count: happy_notes.size
  )

  happy.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "C", "quality" => "major" },
      { "beat" => 3,  "chord" => "F", "quality" => "major" },
      { "beat" => 6,  "chord" => "C", "quality" => "major" },
      { "beat" => 9,  "chord" => "G", "quality" => "dominant" },
      { "beat" => 12, "chord" => "C", "quality" => "major" },
      { "beat" => 15, "chord" => "F", "quality" => "major" },
      { "beat" => 18, "chord" => "C", "quality" => "major" },
      { "beat" => 21, "chord" => "G", "quality" => "dominant" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 12, "level" => 1, "label" => "Verses 1-2" },
      { "start_beat" => 12, "end_beat" => 18, "level" => 2, "label" => "High phrase" },
      { "start_beat" => 18, "end_beat" => 24, "level" => 1, "label" => "Final verse" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 75, "marking" => "mp" },
      { "beat" => 12, "velocity_avg" => 90, "marking" => "f" },
      { "beat" => 18, "velocity_avg" => 80, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Happy Birthday"

# ─── Song 5: Für Elise (Opening Theme) ────────────────────────────────────────
elise = Song.find_or_create_by!(title: "Für Elise (Opening Theme)") do |s|
  s.composer       = "Beethoven"
  s.difficulty     = 2
  s.tempo_bpm      = 80
  s.time_signature = "3/8"
  s.key_signature  = "Am"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if elise.song_parts.empty?
  elise_notes = [
    # E D# E D# E B D C A
    { "pos" => 0,  "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 75, "name" => "Eb5", "dur" => 0.5, "vel" => 70, "beat" => 0.5 },
    { "pos" => 2,  "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 75, "name" => "Eb5", "dur" => 0.5, "vel" => 70, "beat" => 1.5 },
    { "pos" => 4,  "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 2.0 },
    { "pos" => 5,  "midi" => 71, "name" => "B4",  "dur" => 0.5, "vel" => 75, "beat" => 2.5 },
    { "pos" => 6,  "midi" => 74, "name" => "D5",  "dur" => 0.5, "vel" => 75, "beat" => 3.0 },
    { "pos" => 7,  "midi" => 72, "name" => "C5",  "dur" => 0.5, "vel" => 75, "beat" => 3.5 },
    { "pos" => 8,  "midi" => 69, "name" => "A4",  "dur" => 1.0, "vel" => 80, "beat" => 4.0 },
    # C E A B
    { "pos" => 9,  "midi" => 60, "name" => "C4",  "dur" => 0.5, "vel" => 65, "beat" => 5.0 },
    { "pos" => 10, "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 65, "beat" => 5.5 },
    { "pos" => 11, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 70, "beat" => 6.0 },
    { "pos" => 12, "midi" => 71, "name" => "B4",  "dur" => 1.0, "vel" => 75, "beat" => 6.5 },
    # E G# B C
    { "pos" => 13, "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 65, "beat" => 7.5 },
    { "pos" => 14, "midi" => 68, "name" => "Ab4", "dur" => 0.5, "vel" => 70, "beat" => 8.0 },
    { "pos" => 15, "midi" => 71, "name" => "B4",  "dur" => 0.5, "vel" => 75, "beat" => 8.5 },
    { "pos" => 16, "midi" => 72, "name" => "C5",  "dur" => 1.0, "vel" => 80, "beat" => 9.0 },
    # E D# E D# E B D C A (repeat)
    { "pos" => 17, "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 10.0 },
    { "pos" => 18, "midi" => 75, "name" => "Eb5", "dur" => 0.5, "vel" => 70, "beat" => 10.5 },
    { "pos" => 19, "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 11.0 },
    { "pos" => 20, "midi" => 75, "name" => "Eb5", "dur" => 0.5, "vel" => 70, "beat" => 11.5 },
    { "pos" => 21, "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 12.0 },
    { "pos" => 22, "midi" => 71, "name" => "B4",  "dur" => 0.5, "vel" => 75, "beat" => 12.5 },
    { "pos" => 23, "midi" => 74, "name" => "D5",  "dur" => 0.5, "vel" => 75, "beat" => 13.0 },
    { "pos" => 24, "midi" => 72, "name" => "C5",  "dur" => 0.5, "vel" => 75, "beat" => 13.5 },
    { "pos" => 25, "midi" => 69, "name" => "A4",  "dur" => 1.5, "vel" => 80, "beat" => 14.0 }
  ]

  elise.song_parts.create!(
    name: "Melody (Right Hand)",
    hand: "right",
    notes_data: elise_notes,
    note_count: elise_notes.size
  )

  elise.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "Am", "quality" => "minor" },
      { "beat" => 4,  "chord" => "Am", "quality" => "minor" },
      { "beat" => 6,  "chord" => "E",  "quality" => "major" },
      { "beat" => 8,  "chord" => "Am", "quality" => "minor" },
      { "beat" => 10, "chord" => "Am", "quality" => "minor" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 5,  "level" => 2, "label" => "Opening motif" },
      { "start_beat" => 5,  "end_beat" => 10, "level" => 2, "label" => "Arpeggiated answer" },
      { "start_beat" => 10, "end_beat" => 16, "level" => 2, "label" => "Motif repeat" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 70, "marking" => "p" },
      { "beat" => 4,  "velocity_avg" => 80, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 64, "method" => "manual" }
  )
end

puts "  ✓ Für Elise (Opening Theme)"

# ─── Song 6: Canon in D (Simplified) ─────────────────────────────────────────
canon = Song.find_or_create_by!(title: "Canon in D (Simplified)") do |s|
  s.composer       = "Pachelbel"
  s.difficulty     = 2
  s.tempo_bpm      = 72
  s.time_signature = "4/4"
  s.key_signature  = "D"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if canon.song_parts.empty?
  canon_notes = [
    # D F# A D' C# E A C#
    { "pos" => 0,  "midi" => 74, "name" => "D5",  "dur" => 1.0, "vel" => 70, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 73, "name" => "C#5", "dur" => 1.0, "vel" => 70, "beat" => 1.0 },
    { "pos" => 2,  "midi" => 71, "name" => "B4",  "dur" => 1.0, "vel" => 70, "beat" => 2.0 },
    { "pos" => 3,  "midi" => 69, "name" => "A4",  "dur" => 1.0, "vel" => 70, "beat" => 3.0 },
    { "pos" => 4,  "midi" => 67, "name" => "G4",  "dur" => 1.0, "vel" => 70, "beat" => 4.0 },
    { "pos" => 5,  "midi" => 66, "name" => "F#4", "dur" => 1.0, "vel" => 70, "beat" => 5.0 },
    { "pos" => 6,  "midi" => 67, "name" => "G4",  "dur" => 1.0, "vel" => 70, "beat" => 6.0 },
    { "pos" => 7,  "midi" => 69, "name" => "A4",  "dur" => 1.0, "vel" => 75, "beat" => 7.0 },
    # Second pass - stepwise melody
    { "pos" => 8,  "midi" => 66, "name" => "F#4", "dur" => 1.0, "vel" => 75, "beat" => 8.0 },
    { "pos" => 9,  "midi" => 69, "name" => "A4",  "dur" => 1.0, "vel" => 75, "beat" => 9.0 },
    { "pos" => 10, "midi" => 67, "name" => "G4",  "dur" => 1.0, "vel" => 75, "beat" => 10.0 },
    { "pos" => 11, "midi" => 71, "name" => "B4",  "dur" => 1.0, "vel" => 80, "beat" => 11.0 },
    { "pos" => 12, "midi" => 69, "name" => "A4",  "dur" => 1.0, "vel" => 75, "beat" => 12.0 },
    { "pos" => 13, "midi" => 66, "name" => "F#4", "dur" => 1.0, "vel" => 70, "beat" => 13.0 },
    { "pos" => 14, "midi" => 69, "name" => "A4",  "dur" => 1.0, "vel" => 75, "beat" => 14.0 },
    { "pos" => 15, "midi" => 67, "name" => "G4",  "dur" => 1.0, "vel" => 75, "beat" => 15.0 },
    # Third pass - higher register
    { "pos" => 16, "midi" => 74, "name" => "D5",  "dur" => 1.0, "vel" => 80, "beat" => 16.0 },
    { "pos" => 17, "midi" => 73, "name" => "C#5", "dur" => 1.0, "vel" => 80, "beat" => 17.0 },
    { "pos" => 18, "midi" => 74, "name" => "D5",  "dur" => 1.0, "vel" => 85, "beat" => 18.0 },
    { "pos" => 19, "midi" => 74, "name" => "D5",  "dur" => 1.0, "vel" => 80, "beat" => 19.0 },
    { "pos" => 20, "midi" => 71, "name" => "B4",  "dur" => 1.0, "vel" => 80, "beat" => 20.0 },
    { "pos" => 21, "midi" => 69, "name" => "A4",  "dur" => 1.0, "vel" => 75, "beat" => 21.0 },
    { "pos" => 22, "midi" => 71, "name" => "B4",  "dur" => 1.0, "vel" => 80, "beat" => 22.0 },
    { "pos" => 23, "midi" => 69, "name" => "A4",  "dur" => 2.0, "vel" => 80, "beat" => 23.0 }
  ]

  canon.song_parts.create!(
    name: "Melody (Right Hand)",
    hand: "right",
    notes_data: canon_notes,
    note_count: canon_notes.size
  )

  canon.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "D",   "quality" => "major" },
      { "beat" => 2,  "chord" => "Bm",  "quality" => "minor" },
      { "beat" => 4,  "chord" => "G",   "quality" => "major" },
      { "beat" => 6,  "chord" => "A",   "quality" => "major" },
      { "beat" => 8,  "chord" => "D",   "quality" => "major" },
      { "beat" => 10, "chord" => "Bm",  "quality" => "minor" },
      { "beat" => 12, "chord" => "G",   "quality" => "major" },
      { "beat" => 14, "chord" => "A",   "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 8,  "level" => 2, "label" => "Descending theme" },
      { "start_beat" => 8,  "end_beat" => 16, "level" => 2, "label" => "Stepwise variation" },
      { "start_beat" => 16, "end_beat" => 25, "level" => 3, "label" => "Higher register" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 70, "marking" => "p" },
      { "beat" => 8,  "velocity_avg" => 75, "marking" => "mp" },
      { "beat" => 16, "velocity_avg" => 85, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 62, "method" => "manual" }
  )
end

puts "  ✓ Canon in D (Simplified)"

# ─── Song 7: Clocks — Coldplay (Piano Riff) ──────────────────────────────────
clocks = Song.find_or_create_by!(title: "Clocks (Piano Riff)") do |s|
  s.composer       = "Coldplay"
  s.difficulty     = 2
  s.tempo_bpm      = 130
  s.time_signature = "4/4"
  s.key_signature  = "Eb"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if clocks.song_parts.empty?
  clocks_notes = [
    # Eb Bb G pattern (arpeggiated)
    { "pos" => 0,  "midi" => 75, "name" => "Eb5", "dur" => 0.5, "vel" => 85, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 70, "name" => "Bb4", "dur" => 0.5, "vel" => 80, "beat" => 0.5 },
    { "pos" => 2,  "midi" => 67, "name" => "G4",  "dur" => 0.5, "vel" => 75, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 75, "name" => "Eb5", "dur" => 0.5, "vel" => 85, "beat" => 1.5 },
    { "pos" => 4,  "midi" => 70, "name" => "Bb4", "dur" => 0.5, "vel" => 80, "beat" => 2.0 },
    { "pos" => 5,  "midi" => 67, "name" => "G4",  "dur" => 0.5, "vel" => 75, "beat" => 2.5 },
    { "pos" => 6,  "midi" => 75, "name" => "Eb5", "dur" => 0.5, "vel" => 85, "beat" => 3.0 },
    { "pos" => 7,  "midi" => 70, "name" => "Bb4", "dur" => 0.5, "vel" => 80, "beat" => 3.5 },
    # Bb F D pattern
    { "pos" => 8,  "midi" => 74, "name" => "D5",  "dur" => 0.5, "vel" => 85, "beat" => 4.0 },
    { "pos" => 9,  "midi" => 70, "name" => "Bb4", "dur" => 0.5, "vel" => 80, "beat" => 4.5 },
    { "pos" => 10, "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 75, "beat" => 5.0 },
    { "pos" => 11, "midi" => 74, "name" => "D5",  "dur" => 0.5, "vel" => 85, "beat" => 5.5 },
    { "pos" => 12, "midi" => 70, "name" => "Bb4", "dur" => 0.5, "vel" => 80, "beat" => 6.0 },
    { "pos" => 13, "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 75, "beat" => 6.5 },
    { "pos" => 14, "midi" => 74, "name" => "D5",  "dur" => 0.5, "vel" => 85, "beat" => 7.0 },
    { "pos" => 15, "midi" => 70, "name" => "Bb4", "dur" => 0.5, "vel" => 80, "beat" => 7.5 },
    # C Ab F pattern
    { "pos" => 16, "midi" => 72, "name" => "C5",  "dur" => 0.5, "vel" => 80, "beat" => 8.0 },
    { "pos" => 17, "midi" => 68, "name" => "Ab4", "dur" => 0.5, "vel" => 75, "beat" => 8.5 },
    { "pos" => 18, "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 70, "beat" => 9.0 },
    { "pos" => 19, "midi" => 72, "name" => "C5",  "dur" => 0.5, "vel" => 80, "beat" => 9.5 },
    { "pos" => 20, "midi" => 68, "name" => "Ab4", "dur" => 0.5, "vel" => 75, "beat" => 10.0 },
    { "pos" => 21, "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 70, "beat" => 10.5 },
    { "pos" => 22, "midi" => 72, "name" => "C5",  "dur" => 0.5, "vel" => 80, "beat" => 11.0 },
    { "pos" => 23, "midi" => 68, "name" => "Ab4", "dur" => 0.5, "vel" => 75, "beat" => 11.5 }
  ]

  clocks.song_parts.create!(
    name: "Piano Riff (Right Hand)",
    hand: "right",
    notes_data: clocks_notes,
    note_count: clocks_notes.size
  )

  clocks.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0, "chord" => "Eb",  "quality" => "major" },
      { "beat" => 4, "chord" => "Bb",  "quality" => "major" },
      { "beat" => 8, "chord" => "Fm",  "quality" => "minor" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 4,  "level" => 2, "label" => "Eb arpeggio" },
      { "start_beat" => 4,  "end_beat" => 8,  "level" => 2, "label" => "Bb arpeggio" },
      { "start_beat" => 8,  "end_beat" => 12, "level" => 2, "label" => "Fm arpeggio" }
    ],
    dynamics_map: [
      { "beat" => 0, "velocity_avg" => 80, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Clocks (Piano Riff)"

# ─── Song 8: Someone Like You — Adele (Intro) ────────────────────────────────
someone = Song.find_or_create_by!(title: "Someone Like You (Intro)") do |s|
  s.composer       = "Adele"
  s.difficulty     = 2
  s.tempo_bpm      = 68
  s.time_signature = "4/4"
  s.key_signature  = "A"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if someone.song_parts.empty?
  someone_notes = [
    # A major broken chord pattern: A C# E
    { "pos" => 0,  "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 73, "name" => "C#5", "dur" => 0.5, "vel" => 65, "beat" => 0.5 },
    { "pos" => 2,  "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 73, "name" => "C#5", "dur" => 0.5, "vel" => 65, "beat" => 1.5 },
    { "pos" => 4,  "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 2.0 },
    { "pos" => 5,  "midi" => 73, "name" => "C#5", "dur" => 0.5, "vel" => 65, "beat" => 2.5 },
    { "pos" => 6,  "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 70, "beat" => 3.0 },
    { "pos" => 7,  "midi" => 73, "name" => "C#5", "dur" => 0.5, "vel" => 65, "beat" => 3.5 },
    # F#m: F# A C#
    { "pos" => 8,  "midi" => 66, "name" => "F#4", "dur" => 0.5, "vel" => 65, "beat" => 4.0 },
    { "pos" => 9,  "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 4.5 },
    { "pos" => 10, "midi" => 73, "name" => "C#5", "dur" => 0.5, "vel" => 70, "beat" => 5.0 },
    { "pos" => 11, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 5.5 },
    { "pos" => 12, "midi" => 66, "name" => "F#4", "dur" => 0.5, "vel" => 65, "beat" => 6.0 },
    { "pos" => 13, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 6.5 },
    { "pos" => 14, "midi" => 73, "name" => "C#5", "dur" => 0.5, "vel" => 70, "beat" => 7.0 },
    { "pos" => 15, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 7.5 },
    # D: D F# A
    { "pos" => 16, "midi" => 74, "name" => "D5",  "dur" => 0.5, "vel" => 70, "beat" => 8.0 },
    { "pos" => 17, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 8.5 },
    { "pos" => 18, "midi" => 66, "name" => "F#4", "dur" => 0.5, "vel" => 65, "beat" => 9.0 },
    { "pos" => 19, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 9.5 },
    { "pos" => 20, "midi" => 74, "name" => "D5",  "dur" => 0.5, "vel" => 70, "beat" => 10.0 },
    { "pos" => 21, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 10.5 },
    { "pos" => 22, "midi" => 66, "name" => "F#4", "dur" => 0.5, "vel" => 65, "beat" => 11.0 },
    { "pos" => 23, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 65, "beat" => 11.5 },
    # E: E G# B
    { "pos" => 24, "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 75, "beat" => 12.0 },
    { "pos" => 25, "midi" => 71, "name" => "B4",  "dur" => 0.5, "vel" => 70, "beat" => 12.5 },
    { "pos" => 26, "midi" => 68, "name" => "Ab4", "dur" => 0.5, "vel" => 65, "beat" => 13.0 },
    { "pos" => 27, "midi" => 71, "name" => "B4",  "dur" => 0.5, "vel" => 70, "beat" => 13.5 },
    { "pos" => 28, "midi" => 76, "name" => "E5",  "dur" => 0.5, "vel" => 75, "beat" => 14.0 },
    { "pos" => 29, "midi" => 71, "name" => "B4",  "dur" => 0.5, "vel" => 70, "beat" => 14.5 },
    { "pos" => 30, "midi" => 68, "name" => "Ab4", "dur" => 0.5, "vel" => 65, "beat" => 15.0 },
    { "pos" => 31, "midi" => 71, "name" => "B4",  "dur" => 0.5, "vel" => 70, "beat" => 15.5 }
  ]

  someone.song_parts.create!(
    name: "Arpeggio Pattern (Right Hand)",
    hand: "right",
    notes_data: someone_notes,
    note_count: someone_notes.size
  )

  someone.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "A",   "quality" => "major" },
      { "beat" => 4,  "chord" => "F#m", "quality" => "minor" },
      { "beat" => 8,  "chord" => "D",   "quality" => "major" },
      { "beat" => 12, "chord" => "E",   "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 8,  "level" => 2, "label" => "A / F#m arpeggios" },
      { "start_beat" => 8,  "end_beat" => 16, "level" => 2, "label" => "D / E arpeggios" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 65, "marking" => "p" },
      { "beat" => 12, "velocity_avg" => 75, "marking" => "mp" }
    ],
    hand_separation: { "split_midi" => 64, "method" => "manual" }
  )
end

puts "  ✓ Someone Like You (Intro)"

# ─── Song 9: Let It Be — The Beatles (Verse) ─────────────────────────────────
letitbe = Song.find_or_create_by!(title: "Let It Be (Verse)") do |s|
  s.composer       = "The Beatles"
  s.difficulty     = 2
  s.tempo_bpm      = 72
  s.time_signature = "4/4"
  s.key_signature  = "C"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if letitbe.song_parts.empty?
  letitbe_notes = [
    # "When I find my-self in times of trou-ble" (G G G A G E E D)
    { "pos" => 0,  "midi" => 67, "name" => "G4", "dur" => 0.5,  "vel" => 75, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 67, "name" => "G4", "dur" => 0.5,  "vel" => 75, "beat" => 0.5 },
    { "pos" => 2,  "midi" => 67, "name" => "G4", "dur" => 0.5,  "vel" => 75, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 69, "name" => "A4", "dur" => 0.5,  "vel" => 80, "beat" => 1.5 },
    { "pos" => 4,  "midi" => 67, "name" => "G4", "dur" => 1.0,  "vel" => 80, "beat" => 2.0 },
    { "pos" => 5,  "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 75, "beat" => 3.0 },
    { "pos" => 6,  "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 75, "beat" => 3.5 },
    { "pos" => 7,  "midi" => 62, "name" => "D4", "dur" => 1.0,  "vel" => 75, "beat" => 4.0 },
    # "Mo-ther Ma-ry comes to me" (C D E E D C D)
    { "pos" => 8,  "midi" => 60, "name" => "C4", "dur" => 0.5,  "vel" => 75, "beat" => 5.0 },
    { "pos" => 9,  "midi" => 62, "name" => "D4", "dur" => 0.5,  "vel" => 75, "beat" => 5.5 },
    { "pos" => 10, "midi" => 64, "name" => "E4", "dur" => 1.0,  "vel" => 80, "beat" => 6.0 },
    { "pos" => 11, "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 75, "beat" => 7.0 },
    { "pos" => 12, "midi" => 62, "name" => "D4", "dur" => 0.5,  "vel" => 75, "beat" => 7.5 },
    { "pos" => 13, "midi" => 60, "name" => "C4", "dur" => 0.5,  "vel" => 75, "beat" => 8.0 },
    { "pos" => 14, "midi" => 62, "name" => "D4", "dur" => 1.5,  "vel" => 80, "beat" => 8.5 },
    # "Speak-ing words of wis-dom" (G G A G E D)
    { "pos" => 15, "midi" => 67, "name" => "G4", "dur" => 0.5,  "vel" => 80, "beat" => 10.0 },
    { "pos" => 16, "midi" => 67, "name" => "G4", "dur" => 0.5,  "vel" => 80, "beat" => 10.5 },
    { "pos" => 17, "midi" => 69, "name" => "A4", "dur" => 0.5,  "vel" => 85, "beat" => 11.0 },
    { "pos" => 18, "midi" => 67, "name" => "G4", "dur" => 0.5,  "vel" => 80, "beat" => 11.5 },
    { "pos" => 19, "midi" => 64, "name" => "E4", "dur" => 1.0,  "vel" => 80, "beat" => 12.0 },
    { "pos" => 20, "midi" => 62, "name" => "D4", "dur" => 1.0,  "vel" => 75, "beat" => 13.0 },
    # "Let it be" (E D C)
    { "pos" => 21, "midi" => 64, "name" => "E4", "dur" => 1.0,  "vel" => 85, "beat" => 14.0 },
    { "pos" => 22, "midi" => 62, "name" => "D4", "dur" => 1.0,  "vel" => 80, "beat" => 15.0 },
    { "pos" => 23, "midi" => 60, "name" => "C4", "dur" => 2.0,  "vel" => 85, "beat" => 16.0 }
  ]

  letitbe.song_parts.create!(
    name: "Vocal Melody (Right Hand)",
    hand: "right",
    notes_data: letitbe_notes,
    note_count: letitbe_notes.size
  )

  letitbe.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "C",  "quality" => "major" },
      { "beat" => 4,  "chord" => "G",  "quality" => "major" },
      { "beat" => 6,  "chord" => "Am", "quality" => "minor" },
      { "beat" => 8,  "chord" => "F",  "quality" => "major" },
      { "beat" => 10, "chord" => "C",  "quality" => "major" },
      { "beat" => 12, "chord" => "G",  "quality" => "major" },
      { "beat" => 14, "chord" => "F",  "quality" => "major" },
      { "beat" => 16, "chord" => "C",  "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 10, "level" => 2, "label" => "Verse melody" },
      { "start_beat" => 10, "end_beat" => 18, "level" => 1, "label" => "Let it be refrain" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 75, "marking" => "mp" },
      { "beat" => 10, "velocity_avg" => 85, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Let It Be (Verse)"

# ─── Song 10: Imagine — John Lennon (Intro) ──────────────────────────────────
imagine = Song.find_or_create_by!(title: "Imagine (Intro)") do |s|
  s.composer       = "John Lennon"
  s.difficulty     = 2
  s.tempo_bpm      = 76
  s.time_signature = "4/4"
  s.key_signature  = "C"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if imagine.song_parts.empty?
  imagine_notes = [
    # C chord rocking pattern
    { "pos" => 0,  "midi" => 60, "name" => "C4",  "dur" => 0.5, "vel" => 70, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 0.5 },
    { "pos" => 2,  "midi" => 67, "name" => "G4",  "dur" => 0.5, "vel" => 75, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 1.5 },
    { "pos" => 4,  "midi" => 60, "name" => "C4",  "dur" => 0.5, "vel" => 70, "beat" => 2.0 },
    { "pos" => 5,  "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 2.5 },
    { "pos" => 6,  "midi" => 67, "name" => "G4",  "dur" => 0.5, "vel" => 75, "beat" => 3.0 },
    { "pos" => 7,  "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 3.5 },
    # F chord
    { "pos" => 8,  "midi" => 60, "name" => "C4",  "dur" => 0.5, "vel" => 70, "beat" => 4.0 },
    { "pos" => 9,  "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 70, "beat" => 4.5 },
    { "pos" => 10, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 75, "beat" => 5.0 },
    { "pos" => 11, "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 70, "beat" => 5.5 },
    { "pos" => 12, "midi" => 60, "name" => "C4",  "dur" => 0.5, "vel" => 70, "beat" => 6.0 },
    { "pos" => 13, "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 70, "beat" => 6.5 },
    { "pos" => 14, "midi" => 69, "name" => "A4",  "dur" => 0.5, "vel" => 75, "beat" => 7.0 },
    { "pos" => 15, "midi" => 65, "name" => "F4",  "dur" => 0.5, "vel" => 70, "beat" => 7.5 },
    # C chord again
    { "pos" => 16, "midi" => 60, "name" => "C4",  "dur" => 0.5, "vel" => 70, "beat" => 8.0 },
    { "pos" => 17, "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 8.5 },
    { "pos" => 18, "midi" => 67, "name" => "G4",  "dur" => 0.5, "vel" => 75, "beat" => 9.0 },
    { "pos" => 19, "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 9.5 },
    { "pos" => 20, "midi" => 60, "name" => "C4",  "dur" => 0.5, "vel" => 70, "beat" => 10.0 },
    { "pos" => 21, "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 10.5 },
    { "pos" => 22, "midi" => 67, "name" => "G4",  "dur" => 0.5, "vel" => 75, "beat" => 11.0 },
    { "pos" => 23, "midi" => 64, "name" => "E4",  "dur" => 0.5, "vel" => 70, "beat" => 11.5 }
  ]

  imagine.song_parts.create!(
    name: "Piano Pattern (Right Hand)",
    hand: "right",
    notes_data: imagine_notes,
    note_count: imagine_notes.size
  )

  imagine.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0, "chord" => "C", "quality" => "major" },
      { "beat" => 4, "chord" => "F", "quality" => "major" },
      { "beat" => 8, "chord" => "C", "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 4,  "level" => 1, "label" => "C arpeggio" },
      { "start_beat" => 4,  "end_beat" => 8,  "level" => 2, "label" => "F arpeggio" },
      { "start_beat" => 8,  "end_beat" => 12, "level" => 1, "label" => "Return to C" }
    ],
    dynamics_map: [
      { "beat" => 0, "velocity_avg" => 70, "marking" => "p" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Imagine (Intro)"

# ─── Song 11: All of Me — John Legend (Simplified Verse) ─────────────────────
allofme = Song.find_or_create_by!(title: "All of Me (Verse)") do |s|
  s.composer       = "John Legend"
  s.difficulty     = 2
  s.tempo_bpm      = 63
  s.time_signature = "4/4"
  s.key_signature  = "Ab"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if allofme.song_parts.empty?
  allofme_notes = [
    # "What would I do with-out your smart mouth"
    { "pos" => 0,  "midi" => 68, "name" => "Ab4", "dur" => 0.5,  "vel" => 70, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 70, "beat" => 0.5 },
    { "pos" => 2,  "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 75, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 75, "beat" => 1.5 },
    { "pos" => 4,  "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 75, "beat" => 2.0 },
    { "pos" => 5,  "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 70, "beat" => 2.5 },
    { "pos" => 6,  "midi" => 68, "name" => "Ab4", "dur" => 0.5,  "vel" => 70, "beat" => 3.0 },
    { "pos" => 7,  "midi" => 70, "name" => "Bb4", "dur" => 1.0,  "vel" => 70, "beat" => 3.5 },
    # "Draw-in me in and you kick-ing me out"
    { "pos" => 8,  "midi" => 68, "name" => "Ab4", "dur" => 0.5,  "vel" => 70, "beat" => 4.5 },
    { "pos" => 9,  "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 70, "beat" => 5.0 },
    { "pos" => 10, "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 75, "beat" => 5.5 },
    { "pos" => 11, "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 75, "beat" => 6.0 },
    { "pos" => 12, "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 75, "beat" => 6.5 },
    { "pos" => 13, "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 70, "beat" => 7.0 },
    { "pos" => 14, "midi" => 68, "name" => "Ab4", "dur" => 0.5,  "vel" => 70, "beat" => 7.5 },
    { "pos" => 15, "midi" => 67, "name" => "G4",  "dur" => 1.0,  "vel" => 70, "beat" => 8.0 },
    # "You've got my head spin-ning"
    { "pos" => 16, "midi" => 68, "name" => "Ab4", "dur" => 0.5,  "vel" => 75, "beat" => 9.0 },
    { "pos" => 17, "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 75, "beat" => 9.5 },
    { "pos" => 18, "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 80, "beat" => 10.0 },
    { "pos" => 19, "midi" => 75, "name" => "Eb5", "dur" => 1.0,  "vel" => 85, "beat" => 10.5 },
    { "pos" => 20, "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 80, "beat" => 11.5 },
    { "pos" => 21, "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 75, "beat" => 12.0 },
    { "pos" => 22, "midi" => 68, "name" => "Ab4", "dur" => 2.0,  "vel" => 75, "beat" => 12.5 }
  ]

  allofme.song_parts.create!(
    name: "Vocal Melody (Right Hand)",
    hand: "right",
    notes_data: allofme_notes,
    note_count: allofme_notes.size
  )

  allofme.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "Ab",  "quality" => "major" },
      { "beat" => 4,  "chord" => "Fm",  "quality" => "minor" },
      { "beat" => 8,  "chord" => "Db",  "quality" => "major" },
      { "beat" => 12, "chord" => "Eb",  "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 8,  "level" => 2, "label" => "Opening phrases" },
      { "start_beat" => 8,  "end_beat" => 14, "level" => 3, "label" => "Melodic climb" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 70, "marking" => "p" },
      { "beat" => 8,  "velocity_avg" => 80, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 63, "method" => "manual" }
  )
end

puts "  ✓ All of Me (Verse)"

# ─── Song 12: A Thousand Years — Christina Perri (Chorus) ────────────────────
thousand = Song.find_or_create_by!(title: "A Thousand Years (Chorus)") do |s|
  s.composer       = "Christina Perri"
  s.difficulty     = 2
  s.tempo_bpm      = 66
  s.time_signature = "3/4"
  s.key_signature  = "Bb"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if thousand.song_parts.empty?
  thousand_notes = [
    # "I have died ev-ry day wait-ing for you"
    { "pos" => 0,  "midi" => 70, "name" => "Bb4", "dur" => 1.0,  "vel" => 80, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 69, "name" => "A4",  "dur" => 0.5,  "vel" => 75, "beat" => 1.0 },
    { "pos" => 2,  "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 80, "beat" => 1.5 },
    { "pos" => 3,  "midi" => 72, "name" => "C5",  "dur" => 1.0,  "vel" => 85, "beat" => 2.0 },
    { "pos" => 4,  "midi" => 74, "name" => "D5",  "dur" => 1.5,  "vel" => 85, "beat" => 3.0 },
    { "pos" => 5,  "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 80, "beat" => 4.5 },
    { "pos" => 6,  "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 80, "beat" => 5.0 },
    { "pos" => 7,  "midi" => 69, "name" => "A4",  "dur" => 1.5,  "vel" => 80, "beat" => 5.5 },
    # "Dar-ling don't be a-fraid"
    { "pos" => 8,  "midi" => 70, "name" => "Bb4", "dur" => 1.0,  "vel" => 80, "beat" => 7.0 },
    { "pos" => 9,  "midi" => 69, "name" => "A4",  "dur" => 0.5,  "vel" => 75, "beat" => 8.0 },
    { "pos" => 10, "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 80, "beat" => 8.5 },
    { "pos" => 11, "midi" => 72, "name" => "C5",  "dur" => 1.0,  "vel" => 85, "beat" => 9.0 },
    { "pos" => 12, "midi" => 74, "name" => "D5",  "dur" => 1.5,  "vel" => 90, "beat" => 10.0 },
    { "pos" => 13, "midi" => 72, "name" => "C5",  "dur" => 0.5,  "vel" => 85, "beat" => 11.5 },
    { "pos" => 14, "midi" => 70, "name" => "Bb4", "dur" => 0.5,  "vel" => 80, "beat" => 12.0 },
    { "pos" => 15, "midi" => 69, "name" => "A4",  "dur" => 1.0,  "vel" => 80, "beat" => 12.5 },
    # "I have loved you for a thou-sand years"
    { "pos" => 16, "midi" => 65, "name" => "F4",  "dur" => 0.5,  "vel" => 80, "beat" => 14.0 },
    { "pos" => 17, "midi" => 70, "name" => "Bb4", "dur" => 1.0,  "vel" => 85, "beat" => 14.5 },
    { "pos" => 18, "midi" => 69, "name" => "A4",  "dur" => 0.5,  "vel" => 80, "beat" => 15.5 },
    { "pos" => 19, "midi" => 67, "name" => "G4",  "dur" => 0.5,  "vel" => 80, "beat" => 16.0 },
    { "pos" => 20, "midi" => 65, "name" => "F4",  "dur" => 0.5,  "vel" => 80, "beat" => 16.5 },
    { "pos" => 21, "midi" => 67, "name" => "G4",  "dur" => 0.5,  "vel" => 80, "beat" => 17.0 },
    { "pos" => 22, "midi" => 65, "name" => "F4",  "dur" => 2.0,  "vel" => 85, "beat" => 17.5 }
  ]

  thousand.song_parts.create!(
    name: "Vocal Melody (Right Hand)",
    hand: "right",
    notes_data: thousand_notes,
    note_count: thousand_notes.size
  )

  thousand.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "Bb",  "quality" => "major" },
      { "beat" => 3,  "chord" => "F",   "quality" => "major" },
      { "beat" => 7,  "chord" => "Gm",  "quality" => "minor" },
      { "beat" => 10, "chord" => "Eb",  "quality" => "major" },
      { "beat" => 14, "chord" => "Bb",  "quality" => "major" },
      { "beat" => 17, "chord" => "F",   "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 7,  "level" => 2, "label" => "First phrase" },
      { "start_beat" => 7,  "end_beat" => 14, "level" => 2, "label" => "Second phrase" },
      { "start_beat" => 14, "end_beat" => 20, "level" => 2, "label" => "Thousand years hook" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 80, "marking" => "mf" },
      { "beat" => 10, "velocity_avg" => 90, "marking" => "f" },
      { "beat" => 14, "velocity_avg" => 85, "marking" => "mf" }
    ],
    hand_separation: { "split_midi" => 62, "method" => "manual" }
  )
end

puts "  ✓ A Thousand Years (Chorus)"

# ─── Song 13: Stay With Me — Sam Smith (Chorus) ──────────────────────────────
staywithme = Song.find_or_create_by!(title: "Stay With Me (Chorus)") do |s|
  s.composer       = "Sam Smith"
  s.difficulty     = 1
  s.tempo_bpm      = 84
  s.time_signature = "4/4"
  s.key_signature  = "Am"
  s.import_status  = "ready"
  s.source_format  = "manual"
end

if staywithme.song_parts.empty?
  staywithme_notes = [
    # "Won't you stay with me" (E E E C A)
    { "pos" => 0,  "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 0.0 },
    { "pos" => 1,  "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 0.5 },
    { "pos" => 2,  "midi" => 64, "name" => "E4", "dur" => 1.0,  "vel" => 85, "beat" => 1.0 },
    { "pos" => 3,  "midi" => 60, "name" => "C4", "dur" => 1.0,  "vel" => 80, "beat" => 2.0 },
    { "pos" => 4,  "midi" => 69, "name" => "A4", "dur" => 2.0,  "vel" => 85, "beat" => 3.0 },
    # "'Cause you're all I need" (E E E C A)
    { "pos" => 5,  "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 5.0 },
    { "pos" => 6,  "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 5.5 },
    { "pos" => 7,  "midi" => 64, "name" => "E4", "dur" => 1.0,  "vel" => 85, "beat" => 6.0 },
    { "pos" => 8,  "midi" => 60, "name" => "C4", "dur" => 1.0,  "vel" => 80, "beat" => 7.0 },
    { "pos" => 9,  "midi" => 69, "name" => "A4", "dur" => 2.0,  "vel" => 85, "beat" => 8.0 },
    # "This ain't love it's clear to see" (E E E E D C A)
    { "pos" => 10, "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 10.0 },
    { "pos" => 11, "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 10.5 },
    { "pos" => 12, "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 11.0 },
    { "pos" => 13, "midi" => 64, "name" => "E4", "dur" => 0.5,  "vel" => 80, "beat" => 11.5 },
    { "pos" => 14, "midi" => 62, "name" => "D4", "dur" => 1.0,  "vel" => 80, "beat" => 12.0 },
    { "pos" => 15, "midi" => 60, "name" => "C4", "dur" => 1.0,  "vel" => 80, "beat" => 13.0 },
    { "pos" => 16, "midi" => 69, "name" => "A4", "dur" => 2.0,  "vel" => 85, "beat" => 14.0 },
    # "But darling stay with me" (E D C A)
    { "pos" => 17, "midi" => 64, "name" => "E4", "dur" => 1.0,  "vel" => 85, "beat" => 16.0 },
    { "pos" => 18, "midi" => 62, "name" => "D4", "dur" => 1.0,  "vel" => 80, "beat" => 17.0 },
    { "pos" => 19, "midi" => 60, "name" => "C4", "dur" => 1.0,  "vel" => 80, "beat" => 18.0 },
    { "pos" => 20, "midi" => 57, "name" => "A3", "dur" => 2.0,  "vel" => 85, "beat" => 19.0 }
  ]

  staywithme.song_parts.create!(
    name: "Vocal Melody (Right Hand)",
    hand: "right",
    notes_data: staywithme_notes,
    note_count: staywithme_notes.size
  )

  staywithme.create_song_analysis!(
    chord_progressions: [
      { "beat" => 0,  "chord" => "Am", "quality" => "minor" },
      { "beat" => 4,  "chord" => "F",  "quality" => "major" },
      { "beat" => 8,  "chord" => "C",  "quality" => "major" },
      { "beat" => 12, "chord" => "Am", "quality" => "minor" },
      { "beat" => 16, "chord" => "F",  "quality" => "major" }
    ],
    difficulty_sections: [
      { "start_beat" => 0,  "end_beat" => 10, "level" => 1, "label" => "Repeating phrases" },
      { "start_beat" => 10, "end_beat" => 21, "level" => 1, "label" => "Bridge and resolve" }
    ],
    dynamics_map: [
      { "beat" => 0,  "velocity_avg" => 80, "marking" => "mf" },
      { "beat" => 16, "velocity_avg" => 85, "marking" => "f" }
    ],
    hand_separation: { "split_midi" => 60, "method" => "manual" }
  )
end

puts "  ✓ Stay With Me (Chorus)"

puts "\nSeeded #{Song.count} songs, #{SongPart.count} parts, #{SongAnalysis.count} analyses."
