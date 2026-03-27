import { Controller } from "@hotwired/stimulus"
import { isBlackKey, midiToName } from "utils/midi_notes"

// Renders a virtual piano keyboard (C2–C7 range, 61 keys).
// Exposes highlight() and flash() methods consumed via Stimulus Outlets.
// Listens to midi:noteon / midi:noteoff on document to show pressed keys (amber).
export default class extends Controller {
  // MIDI range to display (61 keys: C2–C7)
  static rangeStart = 36  // C2
  static rangeEnd   = 96  // C7

  connect() {
    this.keys = {}  // midi → element
    this.render()
    this.boundPress   = (e) => this.press(e.detail.midi)
    this.boundRelease = (e) => this.release(e.detail.midi)
    document.addEventListener("midi:noteon",  this.boundPress)
    document.addEventListener("midi:noteoff", this.boundRelease)
  }

  disconnect() {
    document.removeEventListener("midi:noteon",  this.boundPress)
    document.removeEventListener("midi:noteoff", this.boundRelease)
  }

  render() {
    this.element.innerHTML = ""
    const wrapper = document.createElement("div")
    wrapper.style.cssText = "position:relative;display:flex;height:180px;background:#0a0a1a;border-radius:8px;overflow:hidden;padding:8px;justify-content:center;border:1px solid #2a2a44;"

    const start = this.constructor.rangeStart
    const end   = this.constructor.rangeEnd

    // Render white keys first (as a row), then layer black keys on top
    const whiteKeys = []
    const blackKeys = []

    for (let midi = start; midi <= end; midi++) {
      if (!isBlackKey(midi)) whiteKeys.push(midi)
      else blackKeys.push(midi)
    }

    // White keys container (no gap — use border for visual separation so % positioning works)
    const whiteRow = document.createElement("div")
    whiteRow.style.cssText = "display:flex;position:relative;width:100%;"

    whiteKeys.forEach(midi => {
      const key = document.createElement("div")
      key.style.cssText = "flex:1;background:#e8e8f0;border-right:1px solid #c0c0d0;border-bottom:1px solid #a0a0b0;border-radius:0 0 4px 4px;cursor:default;position:relative;box-sizing:border-box;"
      key.dataset.midi = midi

      // Label C keys with octave number
      if (midi % 12 === 0) {
        const label = document.createElement("span")
        label.textContent = midiToName(midi)
        label.style.cssText = "position:absolute;bottom:4px;left:50%;transform:translateX(-50%);font-size:10px;color:#666688;pointer-events:none;user-select:none;font-family:'Space Grotesk',sans-serif;"
        key.appendChild(label)
      }

      whiteRow.appendChild(key)
      this.keys[midi] = key
    })

    wrapper.appendChild(whiteRow)

    // Black keys (positioned absolutely over white keys)
    // Position each black key at the boundary between its two adjacent white keys
    const whiteKeyWidth = 100 / whiteKeys.length
    const blackKeyWidth = whiteKeyWidth * 0.6
    let whiteIndex = 0
    for (let midi = start; midi <= end; midi++) {
      if (!isBlackKey(midi)) {
        whiteIndex++
      } else {
        const key = document.createElement("div")
        // Center the black key on the border between whiteIndex-1 and whiteIndex
        const centerPct = whiteIndex * whiteKeyWidth
        key.style.cssText = `
          position:absolute;
          left:${(centerPct - blackKeyWidth / 2).toFixed(2)}%;
          top:0;
          width:${blackKeyWidth.toFixed(2)}%;
          height:60%;
          background:#1a1a2e;
          border:1px solid #2a2a44;
          border-radius:0 0 3px 3px;
          z-index:2;
          cursor:default;
          box-sizing:border-box;
        `
        key.dataset.midi = midi
        whiteRow.appendChild(key)
        this.keys[midi] = key
      }
    }

    this.element.appendChild(wrapper)
  }

  // Highlight a key as "next to play" (blue)
  highlight(midi) {
    this.clearHighlight()
    const key = this.keys[midi]
    if (key) {
      key.dataset.highlighted = "true"
      key.style.background = isBlackKey(midi) ? "#1a0a3a" : "#cc99ff"
    }
  }

  // Flash a key neon green (correct) or neon red (wrong) briefly
  flash(midi, correct) {
    const key = this.keys[midi]
    if (!key) return
    const black = isBlackKey(midi)
    if (correct) {
      key.style.background = black ? "#0a5a0a" : "#39ff14"
      key.style.boxShadow = "0 0 12px rgba(57,255,20,0.6), inset 0 0 8px rgba(57,255,20,0.2)"
    } else {
      key.style.background = black ? "#4a0a1a" : "#ff2255"
      key.style.boxShadow = "0 0 8px rgba(255,34,85,0.4)"
    }
    setTimeout(() => {
      key.style.background = black ? "#1a1a2e" : "#e8e8f0"
      key.style.boxShadow = "none"
    }, 400)
  }

  clearHighlight() {
    Object.entries(this.keys).forEach(([midi, key]) => {
      delete key.dataset.highlighted
      if (key.dataset.pressed !== "true") {
        key.style.background = isBlackKey(Number(midi)) ? "#1a1a2e" : "#e8e8f0"
      }
    })
  }

  // Track that a key is physically held down on the real piano
  press(midi) {
    const key = this.keys[midi]
    if (!key) return
    key.dataset.pressed = "true"
  }

  // Restore a key to its resting state when released
  release(midi) {
    const key = this.keys[midi]
    if (!key) return
    delete key.dataset.pressed
    if (key.dataset.highlighted === "true") {
      key.style.background = isBlackKey(midi) ? "#1a0a3a" : "#cc99ff"
    } else {
      key.style.background = isBlackKey(midi) ? "#1a1a2e" : "#e8e8f0"
    }
  }
}
