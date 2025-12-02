import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    customerId: Number,
  };

  static targets = ["container"];

  connect() {
    this.element.addEventListener("scroll", this.onScroll.bind(this));
    this.loading = false;
  }

  async onScroll() {
    if (this.element.scrollTop < 50 && !this.loading) {
      this.loading = true;
      await this.loadMore();
      this.loading = false;
    }
  }

  async loadMore() {
    const firstMessage =
      this.containerTarget.querySelector("[data-message-id]");
    if (!firstMessage) return;

    const beforeId = firstMessage.dataset.messageId.replace("msg-", "");
    const loader = document.getElementById(
      `infinite-loading-${this.customerIdValue}`
    );

    loader.classList.remove("hidden");

    try {
      const url = `/customers/${this.customerIdValue}/messages?before_id=${beforeId}`;
      const response = await fetch(url);
      if (!response.ok) throw new Error("Request failed");

      const html = await response.text();

      const prevHeight = this.element.scrollHeight;

      this.containerTarget.insertAdjacentHTML("afterbegin", html);
      const newHeight = this.element.scrollHeight;
      this.element.scrollTop = newHeight - prevHeight;
    } catch (error) {
      console.error(error);
    } finally {
      loader.classList.add("hidden");
    }
  }
}
