import { Controller } from "@hotwired/stimulus"

// Core practice state machine.
// Reads the note sequence from data-practice-notes-value (JSON array).
// Listens for midi:noteon events dispatched by midi_controller.
// Communicates with keyboard_controller via Stimulus Outlets.
export default class extends Controller {
  static targets = ["startButton", "noteDisplay", "noteLabel", "progressBar", "progressText", "scorePanel", "accuracyDisplay"]
  static outlets = ["keyboard"]
  static values  = {
    notes:       Array,
    sessionId:   Number,
    songPartId:  Number,
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    this.started = false
    this.correctCount = 0
    this.incorrectCount = 0
    this.noteStartedAt = null
    this.boundHandleNote = this.handleNoteOn.bind(this)
    document.addEventListener("midi:noteon", this.boundHandleNote)
  }

  disconnect() {
    document.removeEventListener("midi:noteon", this.boundHandleNote)
  }

  start() {
    if (this.notesValue.length === 0) {
      this.noteDisplayTarget.textContent = "No notes found."
      return
    }

    this.started = true
    this.currentIndexValue = 0
    this.correctCount = 0
    this.incorrectCount = 0

    if (this.hasStartButtonTarget) {
      this.startButtonTarget.style.display = "none"
    }

    this.showCurrentNote()
  }

  handleNoteOn(event) {
    if (!this.started) return
    if (this.currentIndexValue >= this.notesValue.length) return

    const { midi, velocity } = event.detail
    const expected = this.notesValue[this.currentIndexValue]
    const correct  = midi === expected.midi
    const responseMs = this.noteStartedAt ? Date.now() - this.noteStartedAt : null

    // Flash keyboard
    if (this.hasKeyboardOutlet) {
      this.keyboardOutlet.flash(midi, correct)
    }

    // Record attempt (fire-and-forget)
    this.recordAttempt({
      notePosition: expected.pos,
      expectedMidi: expected.midi,
      playedMidi:   midi,
      correct,
      responseMs,
      playedVelocity:   velocity,
      expectedVelocity: expected.vel
    })

    if (correct) {
      this.correctCount++
      this.currentIndexValue++
      this.updateProgress()

      if (this.currentIndexValue >= this.notesValue.length) {
        this.complete()
      } else {
        this.showCurrentNote()
      }
    } else {
      this.incorrectCount++
    }
  }

  showCurrentNote() {
    const note = this.notesValue[this.currentIndexValue]
    if (!note) return

    // Highlight keyboard
    if (this.hasKeyboardOutlet) {
      this.keyboardOutlet.highlight(note.midi)
    }

    if (this.hasNoteDisplayTarget) {
      this.noteDisplayTarget.textContent = note.name
    }
    if (this.hasNoteLabelTarget) {
      const dynamics = this.velocityLabel(note.vel)
      this.noteLabelTarget.textContent = `MIDI ${note.midi} · ${dynamics}`
    }

    this.noteStartedAt = Date.now()
  }

  updateProgress() {
    const total   = this.notesValue.length
    const reached = this.currentIndexValue
    const pct     = total > 0 ? (reached / total * 100).toFixed(1) : 0

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${pct}%`
    }
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `${reached} / ${total} notes`
    }
  }

  complete() {
    this.started = false

    if (this.hasKeyboardOutlet) {
      this.keyboardOutlet.clearHighlight()
    }

    // Notify Rails to finalize the session
    fetch(`/practice_sessions/${this.sessionIdValue}/complete`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || ""
      },
      body: JSON.stringify({ notes_reached: this.currentIndexValue }),
      headers: {
        "Accept": "text/vnd.turbo-stream.html, text/html",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]')?.content || ""
      }
    })
    .then(r => r.text())
    .then(html => {
      const total = this.correctCount + this.incorrectCount
      const acc   = total > 0 ? ((this.correctCount / total) * 100).toFixed(1) : "0.0"

      if (this.hasScorePanelTarget) {
        this.scorePanelTarget.style.display = "block"
      }
      if (this.hasAccuracyDisplayTarget) {
        this.accuracyDisplayTarget.textContent = `${acc}%`
      }
      if (this.hasNoteDisplayTarget) {
        this.noteDisplayTarget.textContent = "🎉"
      }
      if (this.hasNoteLabelTarget) {
        this.noteLabelTarget.textContent = "Session complete!"
      }

      Turbo.renderStreamMessage(html)
    })
    .catch(() => {
      // Silently ignore network errors — local score panel still shows
    })
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
    }).catch(() => {})  // fire-and-forget
  }

  velocityLabel(velocity) {
    if (velocity >= 112) return "ff (fortissimo)"
    if (velocity >= 88)  return "f (forte)"
    if (velocity >= 64)  return "mf (mezzo-forte)"
    if (velocity >= 40)  return "mp (mezzo-piano)"
    if (velocity >= 20)  return "p (piano)"
    return "pp (pianissimo)"
  }
}
