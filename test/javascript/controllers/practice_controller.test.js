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

function makeElement(notes = SAMPLE_NOTES, sessionId = 1, songPartId = 1) {
  const el = document.createElement("div")
  el.setAttribute("data-practice-notes-value", JSON.stringify(notes))
  el.setAttribute("data-practice-session-id-value", String(sessionId))
  el.setAttribute("data-practice-song-part-id-value", String(songPartId))

  // Add target elements
  const targets = ["startButton", "noteDisplay", "noteLabel", "progressBar", "progressText", "scorePanel", "accuracyDisplay"]
  targets.forEach(name => {
    const t = document.createElement("div")
    t.setAttribute("data-practice-target", name)
    el.appendChild(t)
  })

  document.body.appendChild(el)
  return el
}

describe("PracticeController", () => {
  let element
  let controller

  beforeEach(() => {
    document.body.innerHTML = ""
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
      expect(controller.notesValue[0].midi).toBe(60)
    })
  })

  describe("start()", () => {
    it("sets started to true", () => {
      controller.start()
      expect(controller.started).toBe(true)
    })

    it("resets counters", () => {
      controller.correctCount = 5
      controller.incorrectCount = 3
      controller.start()
      expect(controller.correctCount).toBe(0)
      expect(controller.incorrectCount).toBe(0)
    })

    it("sets currentIndex to 0", () => {
      controller.currentIndexValue = 2
      controller.start()
      expect(controller.currentIndexValue).toBe(0)
    })

    it("does not start when notes are empty", () => {
      const emptyEl = makeElement([])
      const emptyController = new PracticeController(emptyEl)
      emptyController.connect()
      emptyController.start()
      expect(emptyController.started).toBe(false)
    })
  })

  describe("handleNoteOn() — practice state machine", () => {
    beforeEach(() => {
      controller.start()
    })

    it("advances index on correct note", () => {
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))
      expect(controller.currentIndexValue).toBe(1)
    })

    it("increments correctCount on correct note", () => {
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))
      expect(controller.correctCount).toBe(1)
    })

    it("does not advance on wrong note", () => {
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 62, velocity: 80 } }))
      expect(controller.currentIndexValue).toBe(0)
    })

    it("increments incorrectCount on wrong note", () => {
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 62, velocity: 80 } }))
      expect(controller.incorrectCount).toBe(1)
    })

    it("calls recordAttempt (fetch) for each note", () => {
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))
      expect(fetch).toHaveBeenCalledOnce()
    })

    it("does nothing when not started", () => {
      controller.started = false
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 80 } }))
      expect(controller.currentIndexValue).toBe(0)
    })
  })

  describe("recordAttempt() — velocity data", () => {
    beforeEach(() => {
      controller.start()
    })

    it("sends played_velocity and expected_velocity in the fetch body", () => {
      controller.handleNoteOn(new CustomEvent("midi:noteon", { detail: { midi: 60, velocity: 95 } }))

      const fetchCall = fetch.mock.calls[0]
      const body = JSON.parse(fetchCall[1].body)
      expect(body.attempt.played_velocity).toBe(95)
      expect(body.attempt.expected_velocity).toBe(80) // from SAMPLE_NOTES[0].vel
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
