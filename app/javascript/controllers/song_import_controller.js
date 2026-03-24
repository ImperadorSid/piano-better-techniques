import { Controller } from "@hotwired/stimulus"

// Handles the song import form.
// Shows a status message while the import is processing.
export default class extends Controller {
  static targets = ["status"]

  connect() {
    // Check if we landed here after a redirect from a pending import
    const url = new URL(window.location.href)
    if (url.searchParams.get("importing") === "1") {
      this.pollStatus(url.searchParams.get("song_id"))
    }
  }

  submitStart() {
    if (this.hasStatusTarget) {
      this.statusTarget.style.display = "block"
      this.statusTarget.textContent = "Importing song... this may take a moment."
    }
  }

  pollStatus(songId) {
    if (!songId) return
    const interval = setInterval(async () => {
      try {
        const response = await fetch(`/songs/${songId}.json`)
        if (!response.ok) return
        const data = await response.json()
        if (data.import_status === "ready") {
          clearInterval(interval)
          window.location.href = `/songs/${songId}`
        } else if (data.import_status === "failed") {
          clearInterval(interval)
          if (this.hasStatusTarget) {
            this.statusTarget.textContent = "Import failed. Please try again."
            this.statusTarget.style.color = "#ee5555"
          }
        }
      } catch (e) {
        // ignore transient errors
      }
    }, 2000)
  }
}
