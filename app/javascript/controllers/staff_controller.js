import { Controller } from "@hotwired/stimulus"
import { Renderer, Stave, StaveNote, Voice, Formatter, Accidental, Barline } from "vexflow"

const MEASURES_VISIBLE = 3
const STAVE_HEIGHT = 120

// Renders a mini staff notation display using VexFlow.
// Shows 3 measures at a time with bar lines, highlighting the current note.
// Consumed by practice_controller via Stimulus Outlets.
export default class extends Controller {
  static values = {
    beatsPerMeasure: { type: Number, default: 4 }
  }

  connect() {
    // Rendering is triggered by practice_controller calling showNotes()
  }

  disconnect() {
    this.element.innerHTML = ""
  }

  showNotes(currentIndex, allNotes) {
    const measures = this._groupByMeasure(allNotes)
    const currentMeasureIndex = this._measureIndexForNote(allNotes, currentIndex)
    const { visibleMeasures, startMeasure } = this._computeVisibleMeasures(measures, currentMeasureIndex)
    const activeNoteIndex = currentIndex
    this._render(visibleMeasures, startMeasure, allNotes, activeNoteIndex)
  }

  clear() {
    this.element.innerHTML = ""
  }

  _groupByMeasure(allNotes) {
    const bpm = this.beatsPerMeasureValue
    const measures = []
    allNotes.forEach((note, idx) => {
      const measureNum = note.beat != null ? Math.floor(note.beat / bpm) : 0
      if (!measures[measureNum]) measures[measureNum] = []
      measures[measureNum].push({ ...note, _index: idx })
    })
    // Fill any empty measures with empty arrays
    for (let i = 0; i < measures.length; i++) {
      if (!measures[i]) measures[i] = []
    }
    return measures
  }

  _measureIndexForNote(allNotes, noteIndex) {
    const note = allNotes[noteIndex]
    if (!note || note.beat == null) return 0
    return Math.floor(note.beat / this.beatsPerMeasureValue)
  }

  _computeVisibleMeasures(measures, currentMeasureIndex) {
    // Fixed pages of 3 measures: [0,1,2], [3,4,5], [6,7,8], etc.
    // Only advances when the player finishes all notes in the current page.
    const start = Math.floor(currentMeasureIndex / MEASURES_VISIBLE) * MEASURES_VISIBLE
    const end = Math.min(start + MEASURES_VISIBLE, measures.length)
    return {
      visibleMeasures: measures.slice(start, end),
      startMeasure: start
    }
  }

  _render(visibleMeasures, startMeasure, allNotes, activeNoteIndex) {
    this.element.innerHTML = ""
    if (visibleMeasures.length === 0) return

    const width = Math.max(this.element.clientWidth || 500, 300)

    const renderer = new Renderer(this.element, Renderer.Backends.SVG)
    renderer.resize(width, STAVE_HEIGHT)
    const context = renderer.getContext()

    const clefWidth = 50
    const totalStaveWidth = width - clefWidth
    const measureWidth = totalStaveWidth / visibleMeasures.length

    visibleMeasures.forEach((measureNotes, i) => {
      const x = i === 0 ? 0 : clefWidth + measureWidth * i
      const w = i === 0 ? clefWidth + measureWidth : measureWidth

      const stave = new Stave(x, 10, w)
      if (i === 0) stave.addClef("treble")
      if (i < visibleMeasures.length - 1) {
        stave.setEndBarType(Barline.type.SINGLE)
      }
      stave.setContext(context).draw()

      if (measureNotes.length === 0) return

      const staveNotes = measureNotes.map(note => {
        const vfKey = this._noteNameToVexflow(note.name)
        const vfDur = this._durToVexflow(note.dur)
        const sn = new StaveNote({ keys: [vfKey], duration: vfDur })

        if (note.name.includes("#")) {
          sn.addModifier(new Accidental("#"), 0)
        }

        if (note._index === activeNoteIndex) {
          sn.setStyle({ fillStyle: "#5555ff", strokeStyle: "#5555ff" })
        } else {
          sn.setStyle({ fillStyle: "#aaa", strokeStyle: "#aaa" })
        }

        return sn
      })

      const voice = new Voice({
        num_beats: this.beatsPerMeasureValue,
        beat_value: 4
      })
      voice.setMode(Voice.Mode.SOFT)
      voice.addTickables(staveNotes)

      new Formatter().joinVoices([voice]).format([voice], w - 20)
      voice.draw(context, stave)
    })
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
