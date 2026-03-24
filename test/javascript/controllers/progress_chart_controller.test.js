import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"

vi.mock("@hotwired/stimulus", async () => {
  const { Controller } = await import("../support/stimulus_mock.js")
  return { Controller }
})

// Mock Chart.js since it requires canvas rendering which jsdom doesn't fully support
vi.mock("chart.js", () => ({
  default: vi.fn().mockImplementation(class MockChart {
    constructor() { this.destroy = vi.fn() }
  })
}))

const { default: ProgressChartController } = await import("../../../app/javascript/controllers/progress_chart_controller.js")
import Chart from "chart.js"

describe("ProgressChartController", () => {
  let element
  let controller

  const sampleSessions = [
    { date: "Mar 10", accuracy: 75.0 },
    { date: "Mar 11", accuracy: 82.5 },
    { date: "Mar 12", accuracy: 90.0 }
  ]

  beforeEach(() => {
    document.body.innerHTML = '<div id="chart"><canvas></canvas></div>'
    element = document.getElementById("chart")
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe("connect() with data", () => {
    it("initializes Chart when sessions data is present", () => {
      element.setAttribute("data-progress-chart-sessions-value", JSON.stringify(sampleSessions))
      controller = new ProgressChartController(element)
      controller.connect()
      expect(Chart).toHaveBeenCalledOnce()
    })

    it("does not initialize Chart when sessions is empty", () => {
      element.setAttribute("data-progress-chart-sessions-value", "[]")
      controller = new ProgressChartController(element)
      controller.connect()
      expect(Chart).not.toHaveBeenCalled()
    })
  })

  describe("disconnect()", () => {
    it("destroys the chart on disconnect", () => {
      element.setAttribute("data-progress-chart-sessions-value", JSON.stringify(sampleSessions))
      controller = new ProgressChartController(element)
      controller.connect()
      controller.disconnect()
      expect(controller.chart).toBeNull()
    })
  })
})
