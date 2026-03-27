import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"
Chart.register(...registerables)

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
          borderColor: "#ff00ff",
          backgroundColor: "rgba(255, 0, 255, 0.08)",
          tension: 0.3,
          fill: true,
          pointBackgroundColor: "#00f0ff",
          pointBorderColor: "#00f0ff",
          pointRadius: 4,
          pointHoverRadius: 6,
          borderWidth: 2
        }]
      },
      options: {
        scales: {
          y: {
            min: 0,
            max: 100,
            ticks: { color: "#666688" },
            grid: { color: "#1a1a2e" }
          },
          x: {
            ticks: { color: "#666688" },
            grid: { color: "#1a1a2e" }
          }
        },
        plugins: {
          legend: { labels: { color: "#a0a0cc" } }
        }
      }
    })
  }
}
