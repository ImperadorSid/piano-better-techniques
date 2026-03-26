FactoryBot.define do
  factory :song_analysis do
    song
    chord_progressions { [ { "beat" => 0, "chord" => "C", "quality" => "major" } ] }
    difficulty_sections { [ { "start_beat" => 0, "end_beat" => 8, "level" => 1, "label" => "Intro" } ] }
    dynamics_map { [ { "beat" => 0, "velocity_avg" => 80, "marking" => "Medium" } ] }
    hand_separation { { "split_midi" => 60, "method" => "manual" } }
  end
end
