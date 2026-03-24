import { describe, it, expect, beforeEach, vi } from "vitest"

vi.mock("@hotwired/stimulus", async () => {
  const { Controller } = await import("../support/stimulus_mock.js")
  return { Controller }
})

vi.mock("utils/midi_notes", () => ({
  isBlackKey: (midi) => [1, 3, 6, 8, 10].includes(midi % 12)
}))

// Import keyboard controller after mocks
const { default: KeyboardController } = await import("../../../app/javascript/controllers/keyboard_controller.js")

describe("KeyboardController", () => {
  let element
  let controller

  beforeEach(() => {
    document.body.innerHTML = '<div id="keyboard"></div>'
    element = document.getElementById("keyboard")
    controller = new KeyboardController(element)
    controller.connect()
  })

  describe("render()", () => {
    it("renders a keyboard container inside the element", () => {
      expect(element.querySelector("div")).not.toBeNull()
    })

    it("creates key elements with data-midi attributes", () => {
      const keys = element.querySelectorAll("[data-midi]")
      expect(keys.length).toBeGreaterThan(0)
    })

    it("creates white keys (non-black keys)", () => {
      const allMidis = Array.from(element.querySelectorAll("[data-midi]"))
        .map(k => parseInt(k.dataset.midi))
      const whiteKeys = allMidis.filter(m => ![1, 3, 6, 8, 10].includes(m % 12))
      expect(whiteKeys.length).toBeGreaterThan(0)
    })

    it("creates black keys", () => {
      const allMidis = Array.from(element.querySelectorAll("[data-midi]"))
        .map(k => parseInt(k.dataset.midi))
      const blackKeys = allMidis.filter(m => [1, 3, 6, 8, 10].includes(m % 12))
      expect(blackKeys.length).toBeGreaterThan(0)
    })
  })

  describe("highlight()", () => {
    it("changes key background color for a white key (C4 = MIDI 60)", () => {
      controller.highlight(60)
      const key = element.querySelector("[data-midi='60']")
      expect(key).not.toBeNull()
      expect(key.style.background).not.toBe("white")
    })

    it("marks highlighted key with data attribute", () => {
      controller.highlight(60)
      const key = element.querySelector("[data-midi='60']")
      expect(key.dataset.highlighted).toBe("true")
    })

    it("clears previous highlight before highlighting new key", () => {
      controller.highlight(60)
      controller.highlight(62)
      const c4Key = element.querySelector("[data-midi='60']")
      expect(c4Key.dataset.highlighted).toBeUndefined()
    })
  })

  describe("clearHighlight()", () => {
    it("removes highlighted data attribute from all keys", () => {
      controller.highlight(60)
      controller.clearHighlight()
      const highlighted = element.querySelectorAll("[data-highlighted='true']")
      expect(highlighted.length).toBe(0)
    })
  })

  describe("flash()", () => {
    it("temporarily changes key color on correct note", () => {
      const key = element.querySelector("[data-midi='60']")
      controller.flash(60, true)
      expect(key.style.background).not.toBe("white")
    })

    it("temporarily changes key color on incorrect note", () => {
      const key = element.querySelector("[data-midi='60']")
      controller.flash(60, false)
      expect(key.style.background).not.toBe("white")
    })

    it("does not throw for unknown MIDI note", () => {
      expect(() => controller.flash(21, true)).not.toThrow()
    })
  })
})
