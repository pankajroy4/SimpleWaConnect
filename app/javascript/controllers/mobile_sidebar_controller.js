// app/javascript/controllers/mobile_sidebar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  connect() {
    const isMobile = window.matchMedia("(max-width: 767px)").matches
    const hasOpenChat = !!window.OPEN_CUSTOMER_ID
    if (isMobile && !hasOpenChat) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.sidebarTarget.classList.remove("-translate-x-full")
    this.backdropTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.sidebarTarget.classList.add("-translate-x-full")
    this.backdropTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  toggle() {
    if (this.sidebarTarget.classList.contains("-translate-x-full")) {
      this.open()
    } else {
      this.close()
    }
  }
}
