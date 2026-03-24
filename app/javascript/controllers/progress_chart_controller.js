import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js"

// Renders a Chart.js accuracy-over-time line chart.
// Data passed via data-progress-chart-sessions-value (JSON array of {date, accuracy}).
export default class extends Controller {
  static values = { sessions: Array }

  connect() {
    if (this.sessionsValue.length === 0) return
    this.renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  renderChart() {
    const canvas = this.element.querySelector("canvas") || this.element

    this.chart = new Chart(canvas, {
      type: "line",
      data: {
        labels: this.sessionsValue.map(s => s.date),
        datasets: [{
          label: "Accuracy %",
          data: this.sessionsValue.map(s => s.accuracy),
          borderColor: "#7c7cff",
          backgroundColor: "rgba(124, 124, 255, 0.1)",
          tension: 0.3,
          fill: true,
          pointBackgroundColor: "#7c7cff"
        }]
      },
      options: {
        scales: {
          y: {
            min: 0,
            max: 100,
            ticks: { color: "#888" },
            grid: { color: "#222" }
          },
          x: {
            ticks: { color: "#888" },
            grid: { color: "#222" }
          }
        },
        plugins: {
          legend: { labels: { color: "#b0b0dd" } }
        }
      }
    })
  }
}
