import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"

vi.mock("@hotwired/stimulus", async () => {
  const { Controller } = await import("../support/stimulus_mock.js")
  return { Controller }
})

const { default: PracticeController } = await import("../../../app/javascript/controllers/practice_controller.js")

const SAMPLE_NOTES = [
  { pos: 0, midi: 60, name: "C4", dur: 1.0, vel: 80, beat: 0.0 },
  { pos: 1, midi: 64, name: "E4", dur: 1.0, vel: 80, beat: 1.0 },
  { pos: 2, midi: 67, name: "G4", dur: 1.0, vel: 80, beat: 2.0 }
]

let currentTime = 0
let rafCallback = null
let rafId = 0

function makeElement(notes = SAMPLE_NOTES, sessionId = 1, songPartId = 1, bpm = 120, beatsPerMeasure = 4) {
  const el = document.createElement("div")
  el.setAttribute("data-practice-notes-value", JSON.stringify(notes))
  el.setAttribute("data-practice-session-id-value", String(sessionId))
  el.setAttribute("data-practice-song-part-id-value", String(songPartId))
  el.setAttribute("data-practice-bpm-value", String(bpm))
  el.setAttribute("data-practice-beats-per-measure-value", String(beatsPerMeasure))

  const targets = ["startButton", "restartButton", "countDisplay", "progressBar", "progressText", "scorePanel", "accuracyDisplay", "resultDisplay"]
  targets.forEach(name => {
    const t = document.createElement("div")
    t.setAttribute("data-practice-target", name)
    el.appendChild(t)
  })

  document.body.appendChild(el)
  return el
}

function advanceTime(ms) {
  currentTime += ms
  if (rafCallback) {
    const cb = rafCallback
    rafCallback = null
    cb(currentTime)
  }
}

describe("PracticeController", () => {
  let element
  let controller

  beforeEach(() => {
    document.body.innerHTML = ""
    currentTime = 0
    rafCallback = null
    rafId = 0

    vi.stubGlobal("performance", { now: () => currentTime })
    vi.stubGlobal("requestAnimationFrame", vi.fn((cb) => {
      rafCallback = cb
      return ++rafId
    }))
    vi.stubGlobal("cancelAnimationFrame", vi.fn())
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ text: () => Promise.resolve("") }))

    element = makeElement()
    controller = new PracticeController(element)
    controller.connect()
  })

  afterEach(() => {
    vi.unstubAllGlobals()
    document.removeEventListener("midi:noteon", controller.boundHandleNote)
  })

  describe("initial state", () => {
    it("is not started initially", () => {
      expect(controller.started).toBe(false)
    })

    it("reads notes from data attribute", () => {
      expect(controller.notesValue).toHaveLength(3)
    })

    it("reads bpm from data attribute", () => {
      expect(controller.bpmValue).toBe(120)
    })

    it("computes msPerBeat correctly", () => {
      expect(controller.msPerBeat).toBe(500) // 60000 / 120
    })
  })

  describe("start()", () => {
    it("sets started to true and begins count-in", () => {
      controller.start()
      expect(controller.started).toBe(true)
      expect(controller.countInPhase).toBe(true)
    })

    it("resets counters", () => {
      controller.correctCount = 5
      controller.incorrectCount = 3
      controller.start()
      expect(controller.correctCount).toBe(0)
      expect(controller.incorrectCount).toBe(0)
      expect(controller.missedCount).toBe(0)
    })

    it("does not start when notes are empty", () => {
      const emptyEl = makeElement([])
      const emptyController = new PracticeController(emptyEl)
      emptyController.connect()
      emptyController.start()
      expect(emptyController.started).toBe(false)
    })

    it("starts requestAnimationFrame loop", () => {
      controller.start()
      expect(requestAnimationFrame).toHaveBeenCalled()
    })
  })

  describe("count-in", () => {
    it("displays beat numbers during count-in", () => {
      controller.start()
      const display = element.querySelector("[data-practice-target='countDisplay']")

      // At time 0, beat 1 should show
      advanceTime(0)
      expect(display.textContent).toBe("1")

      // Advance to beat 2
      advanceTime(500)
      expect(display.textContent).toBe("2")
    })

    it("transitions to playback after one measure", () => {
      controller.start()

      // 4 beats at 500ms each = 2000ms for count-in
      advanceTime(0)   // beat 1
      advanceTime(500) // beat 2
      advanceTime(500) // beat 3
      advanceTime(500) // beat 4
      advanceTime(500) // count-in done

      expect(controller.countInPhase).toBe(false)
    })

    it("ignores MIDI input during count-in", () => {
      controller.start()
      advanceTime(0)

      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))
      expect(controller.noteResults.size).toBe(0)
    })
  })

  describe("auto-advance playback", () => {
    function startAndSkipCountIn() {
      controller.start()
      // Skip through count-in (4 beats × 500ms = 2000ms)
      for (let i = 0; i < 4; i++) advanceTime(500)
      // One more tiny tick to enter playback at beat ~0
      advanceTime(1)
    }

    it("marks notes as missed when their window passes", () => {
      startAndSkipCountIn()

      // Advance past first note window (beat 0 to 1 = 500ms)
      advanceTime(600)

      expect(controller.noteResults.get(0)).toBe("missed")
      expect(controller.missedCount).toBe(1)
    })

    it("records correct note when played during window", () => {
      startAndSkipCountIn()

      // We're at beat 0, advance a little into the first note
      advanceTime(100)
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))

      expect(controller.noteResults.get(0)).toBe("correct")
      expect(controller.correctCount).toBe(1)
    })

    it("records incorrect note when wrong midi played during window", () => {
      startAndSkipCountIn()

      advanceTime(100)
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 62, velocity: 80 } }))

      expect(controller.noteResults.get(0)).toBe("incorrect")
      expect(controller.incorrectCount).toBe(1)
    })

    it("ignores duplicate input for already-resolved note", () => {
      startAndSkipCountIn()

      advanceTime(100)
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))

      expect(controller.correctCount).toBe(1) // not 2
    })

    it("completes session after last note window passes", () => {
      startAndSkipCountIn()

      // Total beats: last note at beat 2.0, dur 1.0, so endBeat = 3.0
      // 3.0 beats × 500ms = 1500ms
      advanceTime(1600)

      expect(controller.started).toBe(false)
      expect(cancelAnimationFrame).toHaveBeenCalled()
    })
  })

  describe("activeNoteIndexAtBeat()", () => {
    it("returns 0 for beat 0.5", () => {
      expect(controller.activeNoteIndexAtBeat(0.5)).toBe(0)
    })

    it("returns 1 for beat 1.5", () => {
      expect(controller.activeNoteIndexAtBeat(1.5)).toBe(1)
    })

    it("returns -1 for beat past all notes", () => {
      expect(controller.activeNoteIndexAtBeat(5.0)).toBe(-1)
    })
  })

  describe("restart()", () => {
    it("cancels animation frame and restarts", () => {
      controller.start()
      controller.restart()
      expect(cancelAnimationFrame).toHaveBeenCalled()
      expect(controller.started).toBe(true) // restarted
      expect(controller.correctCount).toBe(0)
      expect(controller.noteResults.size).toBe(0)
    })
  })

  describe("velocityLabel()", () => {
    it("returns Light for velocity < 43", () => {
      expect(controller.velocityLabel(10)).toBe("Light")
    })

    it("returns Medium for velocity 43-84", () => {
      expect(controller.velocityLabel(60)).toBe("Medium")
    })

    it("returns Heavy for velocity >= 85", () => {
      expect(controller.velocityLabel(120)).toBe("Heavy")
    })
  })
})
