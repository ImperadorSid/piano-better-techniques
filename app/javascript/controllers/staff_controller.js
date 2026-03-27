import { Controller } from "@hotwired/stimulus"
import { Renderer, Stave, StaveNote, Voice, Formatter, Accidental, Barline } from "vexflow"

const MEASURES_VISIBLE = 3
const STAVE_HEIGHT = 120

// Renders a mini staff notation display using VexFlow.
// Shows 3 measures at a time with a sweeping vertical playhead line.
// Consumed by practice_controller via Stimulus Outlets.
export default class extends Controller {
  static values = {
    beatsPerMeasure: { type: Number, default: 4 }
  }

  connect() {
    this.staveGeometry = []
    this.playheadLine = null
    this.svgElement = null
    this.currentPageStart = -1
    this.allNotes = []
  }

  disconnect() {
    this.element.innerHTML = ""
  }

  showNotes(currentIndex, allNotes) {
    this.allNotes = allNotes
    const measures = this._groupByMeasure(allNotes)
    const currentMeasureIndex = this._measureIndexForNote(allNotes, currentIndex)
    const { visibleMeasures, startMeasure } = this._computeVisibleMeasures(measures, currentMeasureIndex)
    this.currentPageStart = startMeasure
    this._render(visibleMeasures, startMeasure, allNotes, currentIndex)
  }

  updatePlayhead(currentBeat, allNotes) {
    if (!allNotes) allNotes = this.allNotes
    const bpm = this.beatsPerMeasureValue
    const measureIndex = Math.floor(currentBeat / bpm)

    // Check if we need to change pages
    const pageStart = Math.floor(measureIndex / MEASURES_VISIBLE) * MEASURES_VISIBLE
    if (pageStart !== this.currentPageStart) {
      const measures = this._groupByMeasure(allNotes)
      const { visibleMeasures, startMeasure } = this._computeVisibleMeasures(measures, measureIndex)
      this.currentPageStart = startMeasure
      const activeIdx = this._noteIndexAtBeat(allNotes, currentBeat)
      this._render(visibleMeasures, startMeasure, allNotes, activeIdx)
    }

    // Find the geometry entry for the current beat
    const geo = this.staveGeometry.find(g => currentBeat >= g.startBeat && currentBeat < g.endBeat)
    if (!geo) return

    const frac = (currentBeat - geo.startBeat) / (geo.endBeat - geo.startBeat)
    const pixelX = geo.x + frac * geo.width

    this._ensurePlayhead()
    this._updatePlayheadPosition(pixelX)
  }

  removePlayhead() {
    if (this.playheadLine && this.playheadLine.parentNode) {
      this.playheadLine.parentNode.removeChild(this.playheadLine)
    }
    this.playheadLine = null
  }

  clear() {
    this.element.innerHTML = ""
    this.staveGeometry = []
    this.playheadLine = null
    this.svgElement = null
    this.currentPageStart = -1
  }

  _ensurePlayhead() {
    if (this.playheadLine && this.playheadLine.parentNode) return

    if (!this.svgElement) {
      this.svgElement = this.element.querySelector("svg")
    }
    if (!this.svgElement) return

    this.playheadLine = document.createElementNS("http://www.w3.org/2000/svg", "line")
    this.playheadLine.setAttribute("y1", "10")
    this.playheadLine.setAttribute("y2", String(STAVE_HEIGHT - 10))
    this.playheadLine.setAttribute("stroke", "#ff4444")
    this.playheadLine.setAttribute("stroke-width", "2")
    this.playheadLine.setAttribute("pointer-events", "none")
    this.svgElement.appendChild(this.playheadLine)
  }

  _updatePlayheadPosition(pixelX) {
    if (!this.playheadLine) return
    this.playheadLine.setAttribute("x1", String(pixelX))
    this.playheadLine.setAttribute("x2", String(pixelX))
  }

  _noteIndexAtBeat(allNotes, beat) {
    for (let i = 0; i < allNotes.length; i++) {
      const note = allNotes[i]
      if (beat >= note.beat && beat < note.beat + note.dur) return i
    }
    return 0
  }

  _groupByMeasure(allNotes) {
    const bpm = this.beatsPerMeasureValue
    const measures = []
    allNotes.forEach((note, idx) => {
      const measureNum = note.beat != null ? Math.floor(note.beat / bpm) : 0
      if (!measures[measureNum]) measures[measureNum] = []
      measures[measureNum].push({ ...note, _index: idx })
    })
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
    const start = Math.floor(currentMeasureIndex / MEASURES_VISIBLE) * MEASURES_VISIBLE
    const end = Math.min(start + MEASURES_VISIBLE, measures.length)
    return {
      visibleMeasures: measures.slice(start, end),
      startMeasure: start
    }
  }

  _render(visibleMeasures, startMeasure, _allNotes, activeNoteIndex) {
    this.element.innerHTML = ""
    this.playheadLine = null
    this.staveGeometry = []
    if (visibleMeasures.length === 0) return

    const width = Math.max(this.element.clientWidth || 500, 300)

    const renderer = new Renderer(this.element, Renderer.Backends.SVG)
    renderer.resize(width, STAVE_HEIGHT)
    const context = renderer.getContext()

    this.svgElement = this.element.querySelector("svg")

    const clefWidth = 50
    const totalStaveWidth = width - clefWidth
    const measureWidth = totalStaveWidth / visibleMeasures.length
    const bpm = this.beatsPerMeasureValue

    visibleMeasures.forEach((measureNotes, i) => {
      const x = i === 0 ? 0 : clefWidth + measureWidth * i
      const w = i === 0 ? clefWidth + measureWidth : measureWidth
      const measureIdx = startMeasure + i

      // Store geometry for playhead positioning
      this.staveGeometry.push({
        measureIndex: measureIdx,
        x: x,
        width: w,
        startBeat: measureIdx * bpm,
        endBeat: (measureIdx + 1) * bpm
      })

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
        num_beats: bpm,
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
