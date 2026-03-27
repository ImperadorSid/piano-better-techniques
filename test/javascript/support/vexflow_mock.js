import { vi } from "vitest"

const mockContext = {
  setFont: vi.fn().mockReturnThis(),
  setFillStyle: vi.fn().mockReturnThis(),
  setStrokeStyle: vi.fn().mockReturnThis(),
}

const mockVoice = {
  setMode: vi.fn().mockReturnThis(),
  addTickables: vi.fn().mockReturnThis(),
  draw: vi.fn().mockReturnThis(),
}

const mockFormatter = {
  joinVoices: vi.fn().mockReturnThis(),
  format: vi.fn().mockReturnThis(),
}

export function Renderer(container) {
  // Create a real SVG element so querySelector("svg") works
  const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")
  container.appendChild(svg)
  return {
    resize: vi.fn(),
    getContext: vi.fn(() => mockContext),
  }
}
Renderer.Backends = { SVG: 1 }

export function Stave() {
  return {
    addClef: vi.fn().mockReturnThis(),
    setEndBarType: vi.fn().mockReturnThis(),
    setContext: vi.fn().mockReturnThis(),
    draw: vi.fn().mockReturnThis(),
  }
}

export const Barline = { type: { SINGLE: 1, DOUBLE: 2, END: 3 } }

export function StaveNote() {
  return {
    setStyle: vi.fn().mockReturnThis(),
    addModifier: vi.fn().mockReturnThis(),
  }
}

export function Voice() { return mockVoice }
Voice.Mode = { SOFT: 2 }

export function Formatter() { return mockFormatter }

export function Accidental() { return {} }
