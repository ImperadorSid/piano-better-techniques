import { vi } from "vitest"

const Chart = vi.fn().mockImplementation(() => ({
  destroy: vi.fn(),
  update: vi.fn(),
  data: { labels: [], datasets: [] }
}))

export default Chart
