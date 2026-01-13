// app/javascript/controllers/chats_infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static values = { nextPage: String };
  static targets = ["container"];

  connect() {
    this.loading = false;
    this.hasMore = true;
    this.boundOnScroll = this.onScroll.bind(this);
    this.element.addEventListener("scroll", this.boundOnScroll);
    if (!this.nextPageValue || this.nextPageValue.trim() === "") {
      this.hasMore = false;
    }
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.boundOnScroll);
  }

  async onScroll() {
    if (this.loading || !this.hasMore) return;
    // near bottom trigger (down scroll)
    const threshold = 120; // px
    const bottomOffset = this.element.scrollHeight - (this.element.scrollTop + this.element.clientHeight);
    if (bottomOffset > threshold) return;
    this.loading = true;
    try {
      await this.loadMore();
    } finally {
      this.loading = false;
    }
  }

  async loadMore() {
    if (!this.nextPageValue) {
      this.hasMore = false;
      return;
    }

    const loader = document.getElementById("chats-infinite-loader");
    loader?.classList.remove("hidden");

    try {
      const url = `/chats/infinite_scroll?page=${encodeURIComponent(this.nextPageValue)}`;
      const response = await fetch(url, {
        headers: { Accept: "text/html" },
      });

      if (!response.ok) throw new Error("Request failed");
      const html = await response.text();
      if (!html.trim()) {
        this.hasMore = false;
        return;
      }
      const temp = document.createElement("div");
      temp.innerHTML = html.trim();
      const wrapper = temp.firstElementChild;
      if (!wrapper) {
        this.hasMore = false;
        return;
      }

      const newNextPage = wrapper.dataset.nextPage;
      // APPEND (important difference vs messages)
      this.containerTarget.insertAdjacentHTML("beforeend", wrapper.innerHTML);
      // Update cursor
      this.nextPageValue = newNextPage;
      if (!this.nextPageValue || this.nextPageValue.trim() === "") {
        this.hasMore = false;
      }
    } catch (e) {
      console.error(e);
    } finally {
      loader?.classList.add("hidden");
    }
  }
}
