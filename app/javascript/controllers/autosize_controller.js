import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static values = {
    maxHeight: { type: Number, default: 150 }, // adjust
  };

  connect() {
    this.resize();
    this.element.addEventListener("input", () => this.resize());
  }

  resize() {
    const el = this.element;
    el.style.height = "auto";
    const newHeight = el.scrollHeight;

    if (newHeight <= this.maxHeightValue) {
      el.style.overflowY = "hidden";
      el.style.height = newHeight + "px";
    } else {
      el.style.height = this.maxHeightValue + "px";
      el.style.overflowY = "auto";
    }
  }
}
