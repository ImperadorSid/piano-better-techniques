import { Controller } from "@hotwired/stimulus"
import { midiToName } from "utils/midi_notes"

// Bridges the browser WebMIDI API to the rest of the app via custom DOM events.
// Dispatches:
//   midi:noteon  { detail: { midi, velocity, name } }
//   midi:noteoff { detail: { midi } }
export default class extends Controller {
  static targets = ["status", "statusDot", "deviceList", "lastNote"]

  connect() {
    this.requestMidiAccess()
  }

  async requestMidiAccess() {
    if (!navigator.requestMIDIAccess) {
      this.setStatus("WebMIDI not supported in this browser. Use Chrome or Edge.", false)
      return
    }

    try {
      this.midiAccess = await navigator.requestMIDIAccess()
      this.setupInputs()
      this.midiAccess.onstatechange = () => this.setupInputs()
      this.setStatus("Connected", true)
    } catch (err) {
      this.setStatus(`MIDI access denied: ${err.message}`, false)
    }
  }

  setupInputs() {
    const inputs = Array.from(this.midiAccess.inputs.values())

    inputs.forEach(input => {
      input.onmidimessage = (event) => this.handleMidiMessage(event)
    })

    if (this.hasDeviceListTarget) {
      if (inputs.length === 0) {
        this.deviceListTarget.innerHTML = '<p style="color:#666;font-size:0.9rem;">No MIDI devices found. Connect your piano and refresh.</p>'
      } else {
        this.deviceListTarget.innerHTML = inputs
          .map(i => `<div style="color:#90ee90;font-size:0.9rem;">✓ ${i.name}</div>`)
          .join("")
      }
    }

    const connected = inputs.length > 0
    this.setStatus(
      connected ? `${inputs.length} device(s) connected` : "No MIDI devices found",
      connected
    )
  }

  handleMidiMessage(event) {
    const [status, note, velocity] = event.data
    const command = status & 0xf0

    if (command === 0x90 && velocity > 0) {
      // Note On
      const name = midiToName(note)
      if (this.hasLastNoteTarget) {
        this.lastNoteTarget.textContent = `${name} (MIDI ${note})`
      }
      this.dispatch("noteon", {
        detail: { midi: note, velocity, name },
        bubbles: true,
        target: document
      })
    } else if (command === 0x80 || (command === 0x90 && velocity === 0)) {
      // Note Off
      this.dispatch("noteoff", {
        detail: { midi: note },
        bubbles: true,
        target: document
      })
    }
  }

  setStatus(message, connected) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = `MIDI: ${message}`
    }
    if (this.hasStatusDotTarget) {
      this.statusDotTarget.style.background = connected ? "#90ee90" : "#555"
    }
  }
}
