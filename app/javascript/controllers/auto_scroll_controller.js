import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  connect() {
    this.scrollToBottom({ immediate: true });
    this.observer = new MutationObserver((mutations) => {
      if (mutations.some((m) => m.addedNodes && m.addedNodes.length)) {
        if (this.isNearBottom()) this.scrollToBottom();
      }
    });

    this.observer.observe(this.element, { childList: true, subtree: false });
    document.addEventListener("turbo:submit-end", this.onTurboSubmitEnd);
    this.onTurboFrameLoad = () => {
      if (this.isNearBottom()) this.scrollToBottom();
    };
    this.element.addEventListener("turbo:frame-load", this.onTurboFrameLoad);
  }

  disconnect() {
    if (this.observer) this.observer.disconnect();
    document.removeEventListener("turbo:submit-end", this.onTurboSubmitEnd);
    this.element.removeEventListener("turbo:frame-load", this.onTurboFrameLoad);
  }

  onTurboSubmitEnd = (event) => {
    this.scrollToBottom();
  };

  scrollToBottom({ immediate = false } = {}) {
    const el = this.element;
    const top = el.scrollHeight - el.clientHeight;
    if (top <= 0) return;
    if (immediate) {
      el.scrollTop = el.scrollHeight;
    } else {
      try {
        el.scrollTo({ top: el.scrollHeight, behavior: "smooth" });
      } catch (e) {
        el.scrollTop = el.scrollHeight;
      }
    }
  }

  isNearBottom() {
    const el = this.element;
    const threshold = 120; // px; adjust as you like
    return el.scrollHeight - el.scrollTop - el.clientHeight < threshold;
  }
}
