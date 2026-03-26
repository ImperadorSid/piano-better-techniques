import { defineConfig } from "vitest/config"
import { resolve } from "path"

export default defineConfig({
  resolve: {
    alias: {
      // Map importmap-style bare imports to local mocks or paths
      "@hotwired/stimulus": resolve("./test/javascript/support/stimulus_mock.js"),
      "utils/midi_notes": resolve("./app/javascript/utils/midi_notes.js"),
      "chart.js": resolve("./test/javascript/support/chart_mock.js"),
      "vexflow": resolve("./test/javascript/support/vexflow_mock.js")
    }
  },
  test: {
    environment: "jsdom",
    globals: true,
    include: ["test/javascript/**/*.test.js"]
  }
})
