// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static values = {
    customerId: Number,
    nextPage: String, // Pagy cursor token
  };

  static targets = ["container"];

  connect() {
    this.loading = false;
    this.hasMore = true;
    this.isAdjustingScroll = false;
    this.lastScrollTop = this.element.scrollTop;
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
    if (this.isAdjustingScroll) return;
    const currentTop = this.element.scrollTop;
    const scrollingUp = currentTop < this.lastScrollTop;
    this.lastScrollTop = currentTop;

    if (!scrollingUp) return;
    if (this.loading || !this.hasMore) return;
    if (currentTop > 40) return;
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

    const loader = document.getElementById(`infinite-loading-${this.customerIdValue}`);
    loader?.classList.remove("hidden");
    const prevHeight = this.element.scrollHeight;

    try {
      const url = `/chats/${this.customerIdValue}/messages?page=${encodeURIComponent(this.nextPageValue)}`;

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

      // mark adjustment phase
      this.isAdjustingScroll = true;
      // Insert only message HTML (wrapper contains messages inside)
      this.element.dispatchEvent(new CustomEvent("infinite-scroll:adjusting", { bubbles: true }));

      this.containerTarget.insertAdjacentHTML("afterbegin", wrapper.innerHTML);
      // Update cursor for next request
      this.nextPageValue = newNextPage;
      // If no new cursor => reached end
      if (!this.nextPageValue || this.nextPageValue.trim() === "") {
        this.hasMore = false;
      }
      requestAnimationFrame(() => {
        const newHeight = this.element.scrollHeight;
        this.element.scrollTop = newHeight - prevHeight;
        // unlock after browser settles
        requestAnimationFrame(() => {
          this.element.dispatchEvent(new CustomEvent("infinite-scroll:done", { bubbles: true }));
          this.isAdjustingScroll = false;
        });
      });
    } catch (e) {
      console.error(e);
    } finally {
      loader?.classList.add("hidden");
    }
  }
}
