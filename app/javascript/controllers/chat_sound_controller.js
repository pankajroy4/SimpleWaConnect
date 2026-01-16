import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    sendSrc: String,
    receiveSrc: String,
    volume: { type: Number, default: 0.6 }
  }

  connect() {
    this.sendAudio = this.makeAudio(this.sendSrcValue)
    this.receiveAudio = this.makeAudio(this.receiveSrcValue)

    // browsers require user interaction before audio
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

  makeAudio(src) {
    if (!src) return null
    const a = new Audio(src)
    a.volume = this.volumeValue
    a.preload = "auto"
    return a
  }

  unlock() {
    const a = this.sendAudio || this.receiveAudio
    if (!a) return

    a.muted = true
    a.play().then(() => {
      a.pause()
      a.currentTime = 0
      a.muted = false
      this.unlocked = true
    }).catch(() => {
      this.unlocked = false
    })
  }

  play(audio) {
    if (!this.unlocked || !audio) return
    try {
      audio.currentTime = 0
      audio.play().catch(() => {})
    } catch (_) {}
  }

  send() { this.play(this.sendAudio) }
  receive() { this.play(this.receiveAudio) }
}
