import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    src: String,
    type: String,
  };

  connect() {
    this.loaded = false;
  }

  load() {
    if (this.loaded) return;
    this.loaded = true;

    switch (this.typeValue) {
      case "image":
        this.loadImage();
        break;
      case "video":
        this.loadVideo();
        break;
      case "audio":
        this.loadAudio();
        break;
    }
  }

  loadImage() {
    const img = document.createElement("img");
    img.src = this.srcValue;
    img.className = "w-full h-full object-contain rounded-lg";
    // this.element.replaceWith(img);
    // remove placeholder content
  this.element.innerHTML = "";
  this.element.appendChild(img);

  // disable further clicks
  this.element.removeAttribute("data-action");
  }

  loadVideo() {
    const video = document.createElement("video");
    video.src = this.srcValue;
    video.controls = true;
    video.className = "w-full h-full object-contain rounded-lg bg-black";
    this.element.replaceWith(video);
  }

  loadAudio() {
    const audio = document.createElement("audio");
    audio.src = this.srcValue;
    audio.controls = true;
    audio.className = "w-full";
    this.element.replaceWith(audio);
  }
}
