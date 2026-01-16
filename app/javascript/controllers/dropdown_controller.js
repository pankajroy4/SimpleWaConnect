import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._outsideClickHandler = this._outsideClick.bind(this)
    this._escHandler = this._esc.bind(this)
    document.addEventListener("click", this._outsideClickHandler, true)
    document.addEventListener("keydown", this._escHandler)
  }

  disconnect() {
    document.removeEventListener("click", this._outsideClickHandler, true)
    document.removeEventListener("keydown", this._escHandler)
  }

  _outsideClick(event) {
    // if dropdown is closed, ignore
    if (!this.element.open) return
    // if click is inside dropdown, ignore
    if (this.element.contains(event.target)) return
    // otherwise close
    this.element.open = false
  }

  _esc(event) {
    if (event.key !== "Escape") return
    if (!this.element.open) return
    this.element.open = false
  }
}
