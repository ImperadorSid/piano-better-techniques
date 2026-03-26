import { describe, it, expect, vi, beforeEach } from "vitest"

vi.mock("@hotwired/stimulus", async () => {
  const { Controller } = await import("../support/stimulus_mock.js")
  return { Controller }
})

const { default: StaffController } = await import(
  "../../../app/javascript/controllers/staff_controller.js"
)

const SAMPLE_NOTES = [
  { pos: 0, midi: 60, name: "C4",  dur: 1.0, vel: 80, beat: 0.0 },
  { pos: 1, midi: 62, name: "D4",  dur: 1.0, vel: 80, beat: 1.0 },
  { pos: 2, midi: 64, name: "E4",  dur: 0.5, vel: 80, beat: 2.0 },
  { pos: 3, midi: 65, name: "F4",  dur: 1.0, vel: 80, beat: 2.5 },
  { pos: 4, midi: 67, name: "G4",  dur: 2.0, vel: 80, beat: 3.5 },
  { pos: 5, midi: 69, name: "A4",  dur: 1.0, vel: 80, beat: 5.5 },
  { pos: 6, midi: 71, name: "B4",  dur: 1.0, vel: 80, beat: 6.5 },
  { pos: 7, midi: 72, name: "C5",  dur: 4.0, vel: 80, beat: 7.5 },
]

describe("StaffController", () => {
  let element, controller

  beforeEach(() => {
    document.body.innerHTML = ""
    element = document.createElement("div")
    element.style.width = "500px"
    document.body.appendChild(element)
    controller = new StaffController(element)
    controller.connect()
  })

  describe("showNotes()", () => {
    it("does not throw when called with valid notes", () => {
      expect(() => controller.showNotes(0, SAMPLE_NOTES)).not.toThrow()
    })

    it("does not throw when currentIndex is near the end", () => {
      expect(() => controller.showNotes(7, SAMPLE_NOTES)).not.toThrow()
    })

    it("does not throw with empty notes array", () => {
      expect(() => controller.showNotes(0, [])).not.toThrow()
    })

    it("does not throw with sharp notes", () => {
      const sharpNotes = [{ pos: 0, midi: 61, name: "C#4", dur: 1.0, vel: 80, beat: 0 }]
      expect(() => controller.showNotes(0, sharpNotes)).not.toThrow()
    })
  })

  describe("clear()", () => {
    it("empties the element innerHTML", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      controller.clear()
      expect(element.innerHTML).toBe("")
    })
  })

  describe("_noteNameToVexflow()", () => {
    it("converts C4 to c/4", () => {
      expect(controller._noteNameToVexflow("C4")).toBe("c/4")
    })

    it("converts C#4 to c#/4", () => {
      expect(controller._noteNameToVexflow("C#4")).toBe("c#/4")
    })

    it("converts A2 to a/2", () => {
      expect(controller._noteNameToVexflow("A2")).toBe("a/2")
    })

    it("returns c/4 for invalid input", () => {
      expect(controller._noteNameToVexflow("xyz")).toBe("c/4")
    })
  })

  describe("_durToVexflow()", () => {
    it("maps 1.0 to q (quarter)", () => {
      expect(controller._durToVexflow(1)).toBe("q")
    })

    it("maps 0.5 to 8 (eighth)", () => {
      expect(controller._durToVexflow(0.5)).toBe("8")
    })

    it("maps 2.0 to h (half)", () => {
      expect(controller._durToVexflow(2)).toBe("h")
    })

    it("maps 4.0 to w (whole)", () => {
      expect(controller._durToVexflow(4)).toBe("w")
    })

    it("maps 0.25 to 16 (sixteenth)", () => {
      expect(controller._durToVexflow(0.25)).toBe("16")
    })

    it("defaults to q for unknown duration", () => {
      expect(controller._durToVexflow(3.7)).toBe("q")
    })
  })

  describe("_computeWindow()", () => {
    it("returns WINDOW_SIZE notes starting from currentIndex", () => {
      const { windowNotes, activeOffset } = controller._computeWindow(0, SAMPLE_NOTES)
      expect(windowNotes.length).toBe(6)
      expect(activeOffset).toBe(0)
    })

    it("sets activeOffset correctly for middle index", () => {
      const { windowNotes, activeOffset } = controller._computeWindow(3, SAMPLE_NOTES)
      // Notes 3-8 = 5 remaining, but window shifts back to fill 6
      expect(windowNotes.length).toBe(6)
      expect(activeOffset).toBe(1)
    })

    it("shifts window back when near end to fill WINDOW_SIZE", () => {
      const { windowNotes, activeOffset } = controller._computeWindow(7, SAMPLE_NOTES)
      expect(windowNotes.length).toBe(6)
      expect(activeOffset).toBe(5)
    })

    it("handles arrays shorter than WINDOW_SIZE", () => {
      const short = SAMPLE_NOTES.slice(0, 3)
      const { windowNotes, activeOffset } = controller._computeWindow(1, short)
      // Only 2 notes from index 1 onward, no shift since array < WINDOW_SIZE
      expect(windowNotes.length).toBe(2)
      expect(activeOffset).toBe(0)
    })

    it("handles single-note array", () => {
      const single = [SAMPLE_NOTES[0]]
      const { windowNotes, activeOffset } = controller._computeWindow(0, single)
      expect(windowNotes.length).toBe(1)
      expect(activeOffset).toBe(0)
    })
  })
})
