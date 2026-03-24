import { Controller } from "@hotwired/stimulus"
import { isBlackKey } from "utils/midi_notes"

// Renders a virtual piano keyboard (C3–B5 range, 3 octaves).
// Exposes highlight() and flash() methods consumed via Stimulus Outlets.
export default class extends Controller {
  // MIDI range to display
  static rangeStart = 48  // C3
  static rangeEnd   = 84  // C6

  connect() {
    this.keys = {}  // midi → element
    this.render()
  }

  render() {
    this.element.innerHTML = ""
    const wrapper = document.createElement("div")
    wrapper.style.cssText = "position:relative;display:flex;height:140px;background:#111;border-radius:8px;overflow:hidden;padding:8px;gap:2px;justify-content:center;"

    const start = this.constructor.rangeStart
    const end   = this.constructor.rangeEnd

    // Render white keys first (as a row), then layer black keys on top
    const whiteKeys = []
    const blackKeys = []

    for (let midi = start; midi <= end; midi++) {
      if (!isBlackKey(midi)) whiteKeys.push(midi)
      else blackKeys.push(midi)
    }

    // White keys container
    const whiteRow = document.createElement("div")
    whiteRow.style.cssText = "display:flex;gap:2px;position:relative;width:100%;"

    whiteKeys.forEach(midi => {
      const key = document.createElement("div")
      key.style.cssText = "flex:1;background:white;border:1px solid #666;border-radius:0 0 4px 4px;cursor:default;position:relative;"
      key.dataset.midi = midi
      whiteRow.appendChild(key)
      this.keys[midi] = key
    })

    wrapper.appendChild(whiteRow)

    // Black keys (positioned absolutely over white keys)
    // We compute position by counting white keys
    let whiteIndex = 0
    for (let midi = start; midi <= end; midi++) {
      if (!isBlackKey(midi)) {
        whiteIndex++
      } else {
        const key = document.createElement("div")
        // Position between the two surrounding white keys
        const leftPct = ((whiteIndex - 0.5) / whiteKeys.length * 100).toFixed(2)
        key.style.cssText = `
          position:absolute;
          left:calc(${leftPct}% - 1px);
          top:0;
          width:calc(${(100 / whiteKeys.length * 0.6).toFixed(2)}%);
          height:60%;
          background:#222;
          border:1px solid #555;
          border-radius:0 0 3px 3px;
          z-index:2;
          cursor:default;
        `
        key.dataset.midi = midi
        wrapper.appendChild(key)
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
      key.style.background = isBlackKey(midi) ? "#2244aa" : "#aabbff"
    }
  }

  // Flash a key green (correct) or red (wrong) briefly
  flash(midi, correct) {
    const key = this.keys[midi]
    if (!key) return
    const color = correct
      ? (isBlackKey(midi) ? "#1a5a1a" : "#90ee90")
      : (isBlackKey(midi) ? "#5a1a1a" : "#ee9090")

    key.style.background = color
    setTimeout(() => {
      if (key.dataset.highlighted === "true") {
        key.style.background = isBlackKey(midi) ? "#2244aa" : "#aabbff"
      } else {
        key.style.background = isBlackKey(midi) ? "#222" : "white"
      }
    }, 400)
  }

  clearHighlight() {
    Object.entries(this.keys).forEach(([midi, key]) => {
      delete key.dataset.highlighted
      key.style.background = isBlackKey(Number(midi)) ? "#222" : "white"
    })
  }
}
