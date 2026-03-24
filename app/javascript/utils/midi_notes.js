// MIDI number ↔ note name conversion utilities

const NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

export function midiToName(midi) {
  const octave = Math.floor(midi / 12) - 1
  const name = NOTE_NAMES[midi % 12]
  return `${name}${octave}`
}

export function nameToMidi(name) {
  const match = name.match(/^([A-G]#?)(-?\d+)$/)
  if (!match) return null
  const noteIndex = NOTE_NAMES.indexOf(match[1])
  const octave = parseInt(match[2], 10)
  return (octave + 1) * 12 + noteIndex
}

export function isBlackKey(midi) {
  const pos = midi % 12
  return [1, 3, 6, 8, 10].includes(pos)
}

export function midiToOctave(midi) {
  return Math.floor(midi / 12) - 1
}
