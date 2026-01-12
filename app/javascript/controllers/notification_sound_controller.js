import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    src: String,
    volume: { type: Number, default: 0.6 }
  }

  connect() {
    this.audio = new Audio(this.srcValue)
    this.audio.volume = this.volumeValue
    this.audio.preload = "auto"
    // Browsers require user interaction before audio can play.
    this.unlocked = false
    this._unlockHandler = this.unlock.bind(this)

    window.addEventListener("click", this._unlockHandler, { once: true })
    window.addEventListener("keydown", this._unlockHandler, { once: true })
    window.addEventListener("touchstart", this._unlockHandler, { once: true })
  }

  disconnect() {
    window.removeEventListener("click", this._unlockHandler)
    window.removeEventListener("keydown", this._unlockHandler)
    window.removeEventListener("touchstart", this._unlockHandler)
  }

  unlock() {
    this.audio.muted = true
    this.audio.play().then(() => {
      this.audio.pause()
      this.audio.currentTime = 0
      this.audio.muted = false
      this.unlocked = true
    }).catch(() => {
      this.unlocked = false
    })
  }

  play() {
    if (!this.unlocked) return
    try {
      this.audio.currentTime = 0
      this.audio.play().catch(() => { })
    } catch (_) { }
  }
}
