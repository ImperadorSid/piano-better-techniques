import { Controller } from "@hotwired/stimulus"
import { Renderer, Stave, StaveNote, Voice, Formatter, Accidental } from "vexflow"

const WINDOW_SIZE = 6

// Renders a mini staff notation display using VexFlow.
// Shows a sliding window of notes with the current note highlighted.
// Consumed by practice_controller via Stimulus Outlets.
export default class extends Controller {
  connect() {
    // Rendering is triggered by practice_controller calling showNotes()
  }

  disconnect() {
    this.element.innerHTML = ""
  }

  showNotes(currentIndex, allNotes) {
    const { windowNotes, activeOffset } = this._computeWindow(currentIndex, allNotes)
    this._render(windowNotes, activeOffset)
  }

  clear() {
    this.element.innerHTML = ""
  }

  _computeWindow(currentIndex, allNotes) {
    let start = currentIndex
    let end = Math.min(start + WINDOW_SIZE, allNotes.length)
    if (end - start < WINDOW_SIZE && allNotes.length >= WINDOW_SIZE) {
      start = Math.max(0, end - WINDOW_SIZE)
    }
    return {
      windowNotes: allNotes.slice(start, end),
      activeOffset: currentIndex - start
    }
  }

  _render(windowNotes, activeOffset) {
    this.element.innerHTML = ""
    if (windowNotes.length === 0) return

    const width = Math.max(this.element.clientWidth || 500, 300)
    const height = 150

    const renderer = new Renderer(this.element, Renderer.Backends.SVG)
    renderer.resize(width, height)
    const context = renderer.getContext()

    const stave = new Stave(10, 20, width - 20)
    stave.addClef("treble")
    stave.setContext(context).draw()

    const staveNotes = windowNotes.map((note, i) => {
      const vfKey = this._noteNameToVexflow(note.name)
      const vfDur = this._durToVexflow(note.dur)
      const sn = new StaveNote({ keys: [vfKey], duration: vfDur })

      if (note.name.includes("#")) {
        sn.addModifier(new Accidental("#"), 0)
      }

      if (i === activeOffset) {
        sn.setStyle({ fillStyle: "#5555ff", strokeStyle: "#5555ff" })
      } else {
        sn.setStyle({ fillStyle: "#aaa", strokeStyle: "#aaa" })
      }

      return sn
    })

    const voice = new Voice({ num_beats: windowNotes.length, beat_value: 4 })
    voice.setMode(Voice.Mode.SOFT)
    voice.addTickables(staveNotes)

    new Formatter().joinVoices([voice]).format([voice], width - 80)
    voice.draw(context, stave)
  }

  _noteNameToVexflow(name) {
    const match = name.match(/^([A-Ga-g]#?)(-?\d+)$/)
    if (!match) return "c/4"
    return `${match[1].toLowerCase()}/${match[2]}`
  }

  _durToVexflow(dur) {
    const map = { 4: "w", 2: "h", 1: "q", 0.5: "8", 0.25: "16" }
    return map[dur] || "q"
  }
}
