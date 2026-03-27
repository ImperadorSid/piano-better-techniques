import { describe, it, expect, vi, beforeEach } from "vitest"

vi.mock("@hotwired/stimulus", async () => {
  const { Controller } = await import("../support/stimulus_mock.js")
  return { Controller }
})

const { default: StaffController } = await import(
  "../../../app/javascript/controllers/staff_controller.js"
)

// 4/4 time: measure 0 = beats 0-3, measure 1 = beats 4-7, measure 2 = beats 8-11
const SAMPLE_NOTES = [
  { pos: 0, midi: 60, name: "C4", dur: 1.0, vel: 80, beat: 0.0 },
  { pos: 1, midi: 60, name: "C4", dur: 1.0, vel: 80, beat: 1.0 },
  { pos: 2, midi: 67, name: "G4", dur: 1.0, vel: 80, beat: 2.0 },
  { pos: 3, midi: 67, name: "G4", dur: 1.0, vel: 80, beat: 3.0 },
  { pos: 4, midi: 69, name: "A4", dur: 1.0, vel: 80, beat: 4.0 },
  { pos: 5, midi: 69, name: "A4", dur: 1.0, vel: 80, beat: 5.0 },
  { pos: 6, midi: 67, name: "G4", dur: 2.0, vel: 80, beat: 6.0 },
  { pos: 7, midi: 65, name: "F4", dur: 1.0, vel: 80, beat: 8.0 },
  { pos: 8, midi: 65, name: "F4", dur: 1.0, vel: 80, beat: 9.0 },
  { pos: 9, midi: 64, name: "E4", dur: 1.0, vel: 80, beat: 10.0 },
  { pos: 10, midi: 64, name: "E4", dur: 1.0, vel: 80, beat: 11.0 },
  { pos: 11, midi: 62, name: "D4", dur: 1.0, vel: 80, beat: 12.0 },
  { pos: 12, midi: 62, name: "D4", dur: 1.0, vel: 80, beat: 13.0 },
  { pos: 13, midi: 60, name: "C4", dur: 2.0, vel: 80, beat: 14.0 },
]

function makeElement(beatsPerMeasure = 4) {
  const el = document.createElement("div")
  el.setAttribute("data-staff-beats-per-measure-value", String(beatsPerMeasure))
  el.style.width = "500px"
  document.body.appendChild(el)
  return el
}

describe("StaffController", () => {
  let element, controller

  beforeEach(() => {
    document.body.innerHTML = ""
    element = makeElement()
    controller = new StaffController(element)
    controller.connect()
  })

  describe("showNotes()", () => {
    it("does not throw when called with valid notes", () => {
      expect(() => controller.showNotes(0, SAMPLE_NOTES)).not.toThrow()
    })

    it("does not throw when currentIndex is near the end", () => {
      expect(() => controller.showNotes(13, SAMPLE_NOTES)).not.toThrow()
    })

    it("does not throw with empty notes array", () => {
      expect(() => controller.showNotes(0, [])).not.toThrow()
    })

    it("does not throw with sharp notes", () => {
      const sharpNotes = [{ pos: 0, midi: 61, name: "C#4", dur: 1.0, vel: 80, beat: 0 }]
      expect(() => controller.showNotes(0, sharpNotes)).not.toThrow()
    })

    it("populates staveGeometry after render", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      expect(controller.staveGeometry.length).toBe(3)
      expect(controller.staveGeometry[0].startBeat).toBe(0)
      expect(controller.staveGeometry[0].endBeat).toBe(4)
      expect(controller.staveGeometry[1].startBeat).toBe(4)
    })

    it("sets currentPageStart", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      expect(controller.currentPageStart).toBe(0)
    })
  })

  describe("updatePlayhead()", () => {
    it("does not throw when called after showNotes", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      expect(() => controller.updatePlayhead(0.5, SAMPLE_NOTES)).not.toThrow()
    })

    it("creates a playhead SVG line element", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      controller.updatePlayhead(0.5, SAMPLE_NOTES)
      const svg = element.querySelector("svg")
      const line = svg.querySelector("line")
      expect(line).not.toBeNull()
      expect(line.getAttribute("stroke")).toBe("#ff4444")
    })

    it("updates playhead position on subsequent calls", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      controller.updatePlayhead(0.5, SAMPLE_NOTES)
      const line = element.querySelector("svg line")
      const x1 = line.getAttribute("x1")

      controller.updatePlayhead(2.0, SAMPLE_NOTES)
      const x2 = line.getAttribute("x1")
      expect(x1).not.toBe(x2) // position should have changed
    })

    it("triggers page change when beat crosses measure boundary", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      expect(controller.currentPageStart).toBe(0)

      // Beat 12 is in measure 3, which starts page 1 (measures 3-5)
      controller.updatePlayhead(12.5, SAMPLE_NOTES)
      expect(controller.currentPageStart).toBe(3)
    })
  })

  describe("removePlayhead()", () => {
    it("removes the playhead line from SVG", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      controller.updatePlayhead(0.5, SAMPLE_NOTES)
      expect(element.querySelector("svg line")).not.toBeNull()

      controller.removePlayhead()
      expect(element.querySelector("svg line")).toBeNull()
      expect(controller.playheadLine).toBeNull()
    })

    it("does not throw when no playhead exists", () => {
      expect(() => controller.removePlayhead()).not.toThrow()
    })
  })

  describe("clear()", () => {
    it("empties the element innerHTML", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      controller.clear()
      expect(element.innerHTML).toBe("")
    })

    it("resets staveGeometry", () => {
      controller.showNotes(0, SAMPLE_NOTES)
      controller.clear()
      expect(controller.staveGeometry.length).toBe(0)
    })

    it("resets noteResults so notes render without colors", () => {
      controller.noteResults = new Map([[0, "correct"], [1, "missed"]])
      controller.clear()
      expect(controller.noteResults).toBeNull()
      expect(controller._lastResultsCount).toBe(0)
    })
  })

  describe("_groupByMeasure()", () => {
    it("groups notes into measures by beat position", () => {
      const measures = controller._groupByMeasure(SAMPLE_NOTES)
      expect(measures[0].length).toBe(4)
      expect(measures[1].length).toBe(3)
      expect(measures[2].length).toBe(4)
    })

    it("preserves original note index as _index", () => {
      const measures = controller._groupByMeasure(SAMPLE_NOTES)
      expect(measures[0][0]._index).toBe(0)
      expect(measures[1][0]._index).toBe(4)
    })
  })

  describe("_measureIndexForNote()", () => {
    it("returns measure 0 for beat 0", () => {
      expect(controller._measureIndexForNote(SAMPLE_NOTES, 0)).toBe(0)
    })

    it("returns measure 1 for beat 4.0", () => {
      expect(controller._measureIndexForNote(SAMPLE_NOTES, 4)).toBe(1)
    })
  })

  describe("_computeVisibleMeasures()", () => {
    it("shows first page of 3 measures for measure 0", () => {
      const measures = controller._groupByMeasure(SAMPLE_NOTES)
      const { visibleMeasures, startMeasure } = controller._computeVisibleMeasures(measures, 0)
      expect(visibleMeasures.length).toBe(3)
      expect(startMeasure).toBe(0)
    })

    it("stays on same page while within first 3 measures", () => {
      const measures = controller._groupByMeasure(SAMPLE_NOTES)
      const { startMeasure } = controller._computeVisibleMeasures(measures, 2)
      expect(startMeasure).toBe(0)
    })

    it("advances to next page when entering measure 3", () => {
      const measures = controller._groupByMeasure(SAMPLE_NOTES)
      const { startMeasure } = controller._computeVisibleMeasures(measures, 3)
      expect(startMeasure).toBe(3)
    })
  })

  describe("_noteNameToVexflow()", () => {
    it("converts C4 to c/4", () => {
      expect(controller._noteNameToVexflow("C4")).toBe("c/4")
    })

    it("converts C#4 to c#/4", () => {
      expect(controller._noteNameToVexflow("C#4")).toBe("c#/4")
    })

    it("returns c/4 for invalid input", () => {
      expect(controller._noteNameToVexflow("xyz")).toBe("c/4")
    })
  })

  describe("_durToVexflow()", () => {
    it("maps 1.0 to q", () => { expect(controller._durToVexflow(1)).toBe("q") })
    it("maps 0.5 to 8", () => { expect(controller._durToVexflow(0.5)).toBe("8") })
    it("maps 2.0 to h", () => { expect(controller._durToVexflow(2)).toBe("h") })
    it("maps 4.0 to w", () => { expect(controller._durToVexflow(4)).toBe("w") })
    it("defaults to q for unknown", () => { expect(controller._durToVexflow(3.7)).toBe("q") })
  })
})
