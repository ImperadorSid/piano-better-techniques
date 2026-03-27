import { Controller } from "@hotwired/stimulus"

// BPM-based practice state machine.
// Notes auto-advance based on timing. A vertical playhead sweeps the staff.
// A count-in countdown plays one measure before the music starts.
// MIDI input is evaluated against timing windows for accuracy scoring.
export default class extends Controller {
  static targets = ["startButton", "restartButton", "countDisplay", "progressBar", "progressText", "scorePanel", "accuracyDisplay", "resultDisplay"]
  static outlets = ["keyboard", "staff"]
  static values  = {
    notes:           Array,
    sessionId:       Number,
    songPartId:      Number,
    bpm:             { type: Number, default: 120 },
    beatsPerMeasure: { type: Number, default: 4 },
    currentIndex:    { type: Number, default: 0 }
  }

  connect() {
    this.started = false
    this.countInPhase = false
    this.correctCount = 0
    this.incorrectCount = 0
    this.missedCount = 0
    this.noteResults = new Map()
    this.animFrameId = null
    this.boundHandleNote = this.handleNoteOn.bind(this)
    document.addEventListener("midi:noteon", this.boundHandleNote)
  }

  disconnect() {
    document.removeEventListener("midi:noteon", this.boundHandleNote)
    if (this.animFrameId) cancelAnimationFrame(this.animFrameId)
  }

  get msPerBeat() {
    return 60000 / this.bpmValue
  }

  start() {
    if (this.notesValue.length === 0) {
      if (this.hasCountDisplayTarget) this.countDisplayTarget.textContent = "No notes found."
      return
    }

    this.started = true
    this.currentIndexValue = 0
    this.correctCount = 0
    this.incorrectCount = 0
    this.missedCount = 0
    this.noteResults = new Map()

    if (this.hasStartButtonTarget) this.startButtonTarget.style.display = "none"
    if (this.hasRestartButtonTarget) this.restartButtonTarget.style.display = "inline-block"
    if (this.hasScorePanelTarget) this.scorePanelTarget.style.display = "none"
    if (this.hasResultDisplayTarget) this.resultDisplayTarget.style.display = "none"

    // Render initial staff with clean note colors
    if (this.hasStaffOutlet) {
      this.staffOutlet.resetResults()
      this.staffOutlet.showNotes(0, this.notesValue)
    }

    this.startCountIn()
  }

  startCountIn() {
    this.countInPhase = true
    this.countInStartTime = performance.now()

    if (this.hasCountDisplayTarget) this.countDisplayTarget.textContent = "Get ready..."

    this.animFrameId = requestAnimationFrame(this.tick.bind(this))
  }

  tick() {
    if (!this.started) return

    const now = performance.now()

    if (this.countInPhase) {
      this.tickCountIn(now)
    } else {
      this.tickPlayback(now)
    }

    this.animFrameId = requestAnimationFrame(this.tick.bind(this))
  }

  tickCountIn(now) {
    const elapsed = now - this.countInStartTime
    const beatIndex = Math.floor(elapsed / this.msPerBeat)
    const totalCountInBeats = this.beatsPerMeasureValue

    if (beatIndex >= totalCountInBeats) {
      // Count-in finished, begin playback
      this.countInPhase = false
      this.startTime = performance.now()
      if (this.hasCountDisplayTarget) this.countDisplayTarget.textContent = ""
      return
    }

    // Display the current count beat
    const displayBeat = beatIndex + 1
    if (this.hasCountDisplayTarget) {
      this.countDisplayTarget.textContent = String(displayBeat)
    }
  }

  tickPlayback(now) {
    const elapsedMs = now - this.startTime
    const currentBeat = elapsedMs / this.msPerBeat

    // Update playhead and note colors on staff
    if (this.hasStaffOutlet) {
      this.staffOutlet.updatePlayhead(currentBeat, this.notesValue, this.noteResults)
    }

    // Check for missed notes
    this.checkMissedNotes(currentBeat)

    // Update progress
    this.updateProgress(currentBeat)

    // Check if past last note
    const lastNote = this.notesValue[this.notesValue.length - 1]
    const endBeat = lastNote.beat + lastNote.dur
    if (currentBeat >= endBeat) {
      this.complete()
    }
  }

  activeNoteIndexAtBeat(beat) {
    for (let i = 0; i < this.notesValue.length; i++) {
      const note = this.notesValue[i]
      if (beat >= note.beat && beat < note.beat + note.dur) return i
    }
    return -1
  }

  checkMissedNotes(currentBeat) {
    for (let i = 0; i < this.notesValue.length; i++) {
      const note = this.notesValue[i]
      const noteEnd = note.beat + note.dur
      if (noteEnd <= currentBeat && !this.noteResults.has(i)) {
        this.noteResults.set(i, "missed")
        this.missedCount++
        this.recordAttempt({
          notePosition: note.pos,
          expectedMidi: note.midi,
          playedMidi: 0,
          correct: false,
          responseMs: null,
          playedVelocity: 0,
          expectedVelocity: note.vel
        })
      }
    }
  }

  updateProgress(currentBeat) {
    const lastNote = this.notesValue[this.notesValue.length - 1]
    const totalBeats = lastNote.beat + lastNote.dur
    const pct = Math.min((currentBeat / totalBeats * 100), 100).toFixed(1)

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${pct}%`
    }
    if (this.hasProgressTextTarget) {
      const resolved = this.noteResults.size
      this.progressTextTarget.textContent = `${resolved} / ${this.notesValue.length} notes`
    }
  }

  handleNoteOn(event) {
    if (!this.started || this.countInPhase) return

    const { midi, velocity } = event.detail
    const currentBeat = (performance.now() - this.startTime) / this.msPerBeat
    const idx = this.activeNoteIndexAtBeat(currentBeat)

    if (idx === -1) return
    if (this.noteResults.has(idx)) return

    const expected = this.notesValue[idx]
    const correct = midi === expected.midi
    const responseMs = Math.round((performance.now() - this.startTime) - expected.beat * this.msPerBeat)

    // Flash keyboard
    if (this.hasKeyboardOutlet) {
      this.keyboardOutlet.flash(midi, correct)
    }

    this.noteResults.set(idx, correct ? "correct" : "incorrect")
    if (correct) {
      this.correctCount++
    } else {
      this.incorrectCount++
    }

    this.recordAttempt({
      notePosition: expected.pos,
      expectedMidi: expected.midi,
      playedMidi: midi,
      correct,
      responseMs,
      playedVelocity: velocity,
      expectedVelocity: expected.vel
    })
  }

  complete() {
    this.started = false
    if (this.animFrameId) {
      cancelAnimationFrame(this.animFrameId)
      this.animFrameId = null
    }

    // Mark any remaining notes as missed
    for (let i = 0; i < this.notesValue.length; i++) {
      if (!this.noteResults.has(i)) {
        this.noteResults.set(i, "missed")
        this.missedCount++
      }
    }

    if (this.hasStaffOutlet) this.staffOutlet.removePlayhead()

    // Notify Rails
    fetch(`/practice_sessions/${this.sessionIdValue}/complete`, {
      method: "PATCH",
      headers: {
        "Accept": "text/vnd.turbo-stream.html, text/html",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || ""
      },
      body: JSON.stringify({ notes_reached: this.notesValue.length }),
    })
    .then(r => r.text())
    .then(html => {
      const total = this.notesValue.length
      const acc = total > 0 ? ((this.correctCount / total) * 100).toFixed(1) : "0.0"

      if (this.hasScorePanelTarget) this.scorePanelTarget.style.display = "block"
      if (this.hasAccuracyDisplayTarget) this.accuracyDisplayTarget.textContent = `${acc}%`
      if (this.hasCountDisplayTarget) this.countDisplayTarget.textContent = ""
      if (this.hasResultDisplayTarget) {
        this.resultDisplayTarget.textContent = `${this.correctCount} correct · ${this.incorrectCount} wrong · ${this.missedCount} missed`
        this.resultDisplayTarget.style.display = "block"
      }

      Turbo.renderStreamMessage(html)
    })
    .catch(() => {})
  }

  restart() {
    if (this.animFrameId) {
      cancelAnimationFrame(this.animFrameId)
      this.animFrameId = null
    }
    this.started = false

    if (this.hasStaffOutlet) {
      this.staffOutlet.removePlayhead()
      this.staffOutlet.clear()
    }
    if (this.hasScorePanelTarget) this.scorePanelTarget.style.display = "none"
    if (this.hasResultDisplayTarget) this.resultDisplayTarget.style.display = "none"
    // Remove server-rendered session complete card and restore empty turbo frame
    const sessionCard = document.getElementById("session_complete")
    if (sessionCard) {
      sessionCard.replaceWith(Object.assign(document.createElement("turbo-frame"), { id: "session_complete" }))
    }
    if (this.hasRestartButtonTarget) this.restartButtonTarget.style.display = "none"
    if (this.hasProgressBarTarget) this.progressBarTarget.style.width = "0%"
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `0 / ${this.notesValue.length} notes`
    }

    this.start()
  }

  recordAttempt({ notePosition, expectedMidi, playedMidi, correct, responseMs, playedVelocity, expectedVelocity }) {
    fetch(`/song_parts/${this.songPartIdValue}/practice_sessions/${this.sessionIdValue}/attempts`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || ""
      },
      body: JSON.stringify({
        attempt: {
          note_position: notePosition,
          expected_midi: expectedMidi,
          played_midi:   playedMidi,
          correct,
          response_ms:   responseMs,
          played_velocity:   playedVelocity,
          expected_velocity: expectedVelocity
        }
      })
    }).catch(() => {})
  }

  velocityLabel(velocity) {
    if (velocity >= 85)  return "Heavy"
    if (velocity >= 43)  return "Medium"
    return "Light"
  }
}
