import { vi } from "vitest"

const mockContext = {
  setFont: vi.fn().mockReturnThis(),
  setFillStyle: vi.fn().mockReturnThis(),
  setStrokeStyle: vi.fn().mockReturnThis(),
}

const mockRenderer = {
  resize: vi.fn(),
  getContext: vi.fn(() => mockContext),
}

const mockStave = {
  addClef: vi.fn().mockReturnThis(),
  setContext: vi.fn().mockReturnThis(),
  draw: vi.fn().mockReturnThis(),
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

export function Renderer() { return mockRenderer }
Renderer.Backends = { SVG: 1 }

export function Stave() { return mockStave }

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
