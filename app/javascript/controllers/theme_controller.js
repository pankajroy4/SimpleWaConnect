import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iconSun", "iconMoon"]

  connect() {
    this.applySavedTheme()
    this.syncIcons()
  }

  toggle() {
    document.documentElement.classList.toggle("dark")
    this.persistTheme()
    this.syncIcons()
  }

  applySavedTheme() {
    const saved = localStorage.getItem("theme")
    const shouldBeDark = saved === "dark" || (!saved && window.matchMedia("(prefers-color-scheme: dark)").matches)
    document.documentElement.classList.toggle("dark", shouldBeDark)
  }

  persistTheme() {
    const isDark = document.documentElement.classList.contains("dark")
    localStorage.setItem("theme", isDark ? "dark" : "light")
  }

  syncIcons() {
    const isDark = document.documentElement.classList.contains("dark")
    this.iconSunTarget.classList.toggle("hidden", !isDark)
    this.iconMoonTarget.classList.toggle("hidden", isDark)
  }
}
