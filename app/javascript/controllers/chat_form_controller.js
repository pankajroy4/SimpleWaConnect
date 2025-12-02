import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  reset() {
    // Reset entire form
    this.element.reset();

    // Reset textarea height
    const textarea = this.element.querySelector("textarea");
    if (textarea) {
      textarea.style.height = "auto";
    }

    // CLEAR FILE INPUT
    const fileInput = this.element.querySelector("#attachment");
    if (fileInput) {
      fileInput.value = ""; // clears files!
    }

    // CLEAR PREVIEW BOX
    const previewBox = document.getElementById("attachment-preview");
    if (previewBox) {
      previewBox.innerHTML = "";
    }
  }
}
