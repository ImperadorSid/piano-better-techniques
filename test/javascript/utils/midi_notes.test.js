import { describe, it, expect } from "vitest"
import { midiToName, nameToMidi, isBlackKey, midiToOctave } from "../../../app/javascript/utils/midi_notes.js"

describe("midiToName", () => {
  it("converts middle C (60) to C4", () => {
    expect(midiToName(60)).toBe("C4")
  })

  it("converts A4 (69) correctly", () => {
    expect(midiToName(69)).toBe("A4")
  })

  it("converts C#4 (61) correctly", () => {
    expect(midiToName(61)).toBe("C#4")
  })

  it("converts G4 (67) correctly", () => {
    expect(midiToName(67)).toBe("G4")
  })

  it("handles octave 5 (C5 = 72)", () => {
    expect(midiToName(72)).toBe("C5")
  })
})

describe("nameToMidi", () => {
  it("converts C4 to 60", () => {
    expect(nameToMidi("C4")).toBe(60)
  })

  it("converts G4 to 67", () => {
    expect(nameToMidi("G4")).toBe(67)
  })

  it("converts C#4 to 61", () => {
    expect(nameToMidi("C#4")).toBe(61)
  })

  it("returns null for invalid input", () => {
    expect(nameToMidi("invalid")).toBeNull()
  })

  it("round-trips with midiToName", () => {
    for (let midi = 48; midi <= 84; midi++) {
      expect(nameToMidi(midiToName(midi))).toBe(midi)
    }
  })
})

describe("isBlackKey", () => {
  it("returns true for C# (61)", () => {
    expect(isBlackKey(61)).toBe(true)
  })

  it("returns true for F# (66)", () => {
    expect(isBlackKey(66)).toBe(true)
  })

  it("returns false for C (60)", () => {
    expect(isBlackKey(60)).toBe(false)
  })

  it("returns false for E (64)", () => {
    expect(isBlackKey(64)).toBe(false)
  })

  it("returns false for F (65)", () => {
    expect(isBlackKey(65)).toBe(false)
  })
})

describe("midiToOctave", () => {
  it("returns 4 for MIDI 60 (C4)", () => {
    expect(midiToOctave(60)).toBe(4)
  })

  it("returns 5 for MIDI 72 (C5)", () => {
    expect(midiToOctave(72)).toBe(5)
  })
})
