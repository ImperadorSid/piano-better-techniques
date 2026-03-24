import { describe, it, expect, vi, beforeEach } from "vitest"

vi.mock("@hotwired/stimulus", async () => {
  const { Controller } = await import("../support/stimulus_mock.js")
  return { Controller }
})

const { default: SongImportController } = await import("../../../app/javascript/controllers/song_import_controller.js")

describe("SongImportController", () => {
  let element
  let controller

  beforeEach(() => {
    document.body.innerHTML = ""
    const el = document.createElement("div")
    const statusEl = document.createElement("div")
    statusEl.setAttribute("data-song-import-target", "status")
    el.appendChild(statusEl)
    document.body.appendChild(el)
    element = el
    controller = new SongImportController(element)
  })

  describe("submitStart()", () => {
    it("shows the status element", () => {
      const statusEl = element.querySelector("[data-song-import-target='status']")
      statusEl.style.display = "none"
      controller.submitStart()
      expect(statusEl.style.display).not.toBe("none")
    })

    it("sets a loading message in status element", () => {
      controller.submitStart()
      const statusEl = element.querySelector("[data-song-import-target='status']")
      expect(statusEl.textContent.length).toBeGreaterThan(0)
    })
  })

  describe("pollStatus()", () => {
    it("does nothing when songId is falsy", () => {
      vi.stubGlobal("fetch", vi.fn())
      controller.pollStatus(null)
      expect(fetch).not.toHaveBeenCalled()
      vi.unstubAllGlobals()
    })
  })
})
