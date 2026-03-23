// Minimal Stimulus mock for unit testing controllers in isolation.
// Controllers are tested by instantiating them directly with a fake element.

function deriveIdentifier(element, declaredTargets, declaredValueKeys) {
  // Scan child elements for data-*-target attributes matching declared targets
  for (const el of Array.from(element.querySelectorAll("*"))) {
    for (const attr of Array.from(el.attributes)) {
      if (!attr.name.startsWith("data-") || !attr.name.endsWith("-target")) continue
      const targetNames = attr.value.split(/\s+/)
      for (const targetName of targetNames) {
        if (declaredTargets.includes(targetName)) {
          // "data-song-import-target" → "song-import"
          return attr.name.slice(5, -7)
        }
      }
    }
  }

  // Scan element's own attributes for data-*-{valueName}-value patterns
  for (const attr of Array.from(element.attributes)) {
    if (!attr.name.startsWith("data-") || !attr.name.endsWith("-value")) continue
    const middle = attr.name.slice(5, -6) // strip "data-" and "-value"
    for (const valueName of declaredValueKeys) {
      const kebab = valueName.replace(/([A-Z])/g, "-$1").toLowerCase()
      if (middle === kebab) return ""
      if (middle.endsWith(`-${kebab}`)) {
        return middle.slice(0, middle.length - kebab.length - 1)
      }
    }
  }

  return ""
}

export class Controller {
  static targets = []
  static values = {}
  static outlets = []

  constructor(element) {
    this.element = element
    this.identifier = deriveIdentifier(
      element,
      this.constructor.targets || [],
      Object.keys(this.constructor.values || {})
    )
    this._setupTargets()
    this._setupValues()
  }

  _setupTargets() {
    const targets = this.constructor.targets || []
    const id = this.identifier
    targets.forEach(name => {
      const capitalized = name.charAt(0).toUpperCase() + name.slice(1)
      const find = () => {
        if (id) {
          const el = this.element.querySelector(`[data-${id}-target="${name}"]`)
          if (el) return el
        }
        // Fallback: any child with data-*-target containing this name
        return Array.from(this.element.querySelectorAll("*")).find(el =>
          Array.from(el.attributes).some(a => a.name.endsWith("-target") && a.value.split(/\s+/).includes(name))
        ) || null
      }
      const findAll = () => {
        if (id) {
          const els = Array.from(this.element.querySelectorAll(`[data-${id}-target="${name}"]`))
          if (els.length > 0) return els
        }
        return Array.from(this.element.querySelectorAll("*")).filter(el =>
          Array.from(el.attributes).some(a => a.name.endsWith("-target") && a.value.split(/\s+/).includes(name))
        )
      }
      Object.defineProperty(this, `has${capitalized}Target`, { get: () => !!find() })
      Object.defineProperty(this, `${name}Target`, { get: () => find() })
      Object.defineProperty(this, `${name}Targets`, { get: () => findAll() })
    })
  }

  _setupValues() {
    const values = this.constructor.values || {}
    const id = this.identifier
    Object.entries(values).forEach(([name, config]) => {
      const kebabName = name.replace(/([A-Z])/g, "-$1").toLowerCase()
      const attrName = id
        ? `data-${id}-${kebabName}-value`
        : `data-${kebabName}-value`
      const type = typeof config === "object" ? config.type : config
      const defaultVal = typeof config === "object" ? config.default : undefined

      let _value = this._readAttrValue(attrName, type, defaultVal)

      Object.defineProperty(this, `${name}Value`, {
        get: () => _value,
        set: (v) => {
          _value = v
          const callbackName = `${name}ValueChanged`
          if (typeof this[callbackName] === "function") this[callbackName](v)
        }
      })
    })
  }

  _readAttrValue(attrName, type, defaultVal) {
    const raw = this.element.getAttribute(attrName)
    if (raw === null) return defaultVal
    if (type === Array || type === Object) {
      try { return JSON.parse(raw) } catch { return defaultVal }
    }
    if (type === Number) return Number(raw)
    if (type === Boolean) return raw !== "false"
    return raw
  }

  dispatch(eventName, { detail = {}, bubbles = true, target = this.element } = {}) {
    const event = new CustomEvent(eventName, { detail, bubbles })
    target.dispatchEvent(event)
    return event
  }

  connect() {}
  disconnect() {}
}
