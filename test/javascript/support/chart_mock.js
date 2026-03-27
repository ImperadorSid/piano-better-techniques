import { vi } from "vitest"

const _Chart = vi.fn(function() {
  this.destroy = vi.fn()
  this.update = vi.fn()
  this.data = { labels: [], datasets: [] }
})

_Chart.register = vi.fn()

export { _Chart as Chart }
export const registerables = []
