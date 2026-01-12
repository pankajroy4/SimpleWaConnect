import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    nextPage: String,
  };

  static targets = ["container", "loader"];

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

    const scrollTop = this.element.scrollTop;
    const viewHeight = this.element.clientHeight;
    const contentHeight = this.element.scrollHeight;

    // ✅ trigger when near bottom
    const nearBottom = scrollTop + viewHeight >= contentHeight - 120;
    if (!nearBottom) return;

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

    this.loaderTarget?.classList.remove("hidden");

    try {
      // ✅ since you changed path to chats
      const url = `/chats?page=${encodeURIComponent(this.nextPageValue)}`;
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

      // ✅ APPEND
      this.containerTarget.insertAdjacentHTML("beforeend", wrapper.innerHTML);

      this.nextPageValue = newNextPage;

      if (!this.nextPageValue || this.nextPageValue.trim() === "") {
        this.hasMore = false;
      }
    } catch (e) {
      console.error(e);
    } finally {
      this.loaderTarget?.classList.add("hidden");
    }
  }
}
