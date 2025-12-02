import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["password", "passwordConfirmation", "passwordCurrent", "eye", "eyeSlash"]
  toggle() {
    const show = this.passwordTarget.type === "password"

    this.passwordTarget.type = show ? "text" : "password"

    if (this.hasPasswordConfirmationTarget) {
      this.passwordConfirmationTarget.type = show ? "text" : "password"
    }

    if (this.hasPasswordCurrentTarget) {
      this.passwordCurrentTarget.type = show ? "text" : "password"
    }

    if (this.hasEyeTarget) {
      this.eyeTarget.classList.toggle("hidden", show)
    }

    if (this.hasEyeSlashTarget) {
      this.eyeSlashTarget.classList.toggle("hidden", !show)
    }
  }
}