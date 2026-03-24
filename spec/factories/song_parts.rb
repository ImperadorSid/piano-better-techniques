FactoryBot.define do
  factory :song_part do
    song
    name { "Melody" }
    hand { "right" }
    notes_data do
      [
        { "pos" => 0, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
        { "pos" => 1, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 1.0 },
        { "pos" => 2, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 2.0 }
      ]
    end
    note_count { 3 }

    trait :left_hand do
      name { "Accompaniment" }
      hand { "left" }
    end
  end
end
