// import { Controller } from "@hotwired/stimulus";

// export default class extends Controller {
//   static values = {
//     customerId: Number,
//   };

//   static targets = ["container"];

//   connect() {
//     this.element.addEventListener("scroll", this.onScroll.bind(this));
//     this.loading = false;
//   }

//   async onScroll() {
//     if (this.element.scrollTop < 50 && !this.loading) {
//       this.loading = true;
//       await this.loadMore();
//       this.loading = false;
//     }
//   }

//   async loadMore() {
//     const firstMessage =
//       this.containerTarget.querySelector("[data-message-id]");
//     if (!firstMessage) return;

//     const beforeId = firstMessage.dataset.messageId.replace("msg-", "");
//     const loader = document.getElementById(
//       `infinite-loading-${this.customerIdValue}`
//     );

//     loader.classList.remove("hidden");

//     try {
//       const url = `/customers/${this.customerIdValue}/messages?before_id=${beforeId}`;
//       const response = await fetch(url);
//       if (!response.ok) throw new Error("Request failed");

//       const html = await response.text();

//       const prevHeight = this.element.scrollHeight;

//       this.containerTarget.insertAdjacentHTML("afterbegin", html);
//       const newHeight = this.element.scrollHeight;
//       this.element.scrollTop = newHeight - prevHeight;
//     } catch (error) {
//       console.error(error);
//     } finally {
//       loader.classList.add("hidden");
//     }
//   }
// }



import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    customerId: Number,
  };

  static targets = ["container"];

  connect() {
    this.loading = false;
    this.hasMore = true;
    this.isAdjustingScroll = false;
    this.oldestMessageId = null;
    this.lastScrollTop = this.element.scrollTop;
    this.boundOnScroll = this.onScroll.bind(this);
    this.element.addEventListener("scroll", this.boundOnScroll);
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.boundOnScroll);
  }

  async onScroll() {
    // ignore scrolls caused by our own adjustments
    if (this.isAdjustingScroll) return;
    const currentTop = this.element.scrollTop;
    const scrollingUp = currentTop < this.lastScrollTop;
    this.lastScrollTop = currentTop;
    // ignore scroll-down completely
    if (!scrollingUp) return;
    // ignore if already loading or no more data
    if (this.loading || !this.hasMore) return;
    // only trigger very close to top
    if (currentTop > 40) return;
    this.loading = true;
    await this.loadMore();
    this.loading = false;
  }

  async loadMore() {
    const firstMessage =
      this.containerTarget.querySelector("[data-message-id]");

    if (!firstMessage) {
      this.hasMore = false;
      return;
    }

    const beforeId = firstMessage.dataset.messageId.replace("msg-", "");
    // STOP: we already tried loading before this id
    if (this.oldestMessageId === beforeId) {
      this.hasMore = false;
      return;
    }

    this.oldestMessageId = beforeId;

    const loader = document.getElementById(
      `infinite-loading-${this.customerIdValue}`
    );
    loader?.classList.remove("hidden");
    const prevHeight = this.element.scrollHeight;

    try {
      const response = await fetch(
        `/customers/${this.customerIdValue}/messages?before_id=${beforeId}`
      );

      if (!response.ok) throw new Error("Request failed");
      const html = await response.text();
      if (!html.trim()) {
        this.hasMore = false;
        return;
      }

      // mark adjustment phase
      this.isAdjustingScroll = true;
      this.containerTarget.insertAdjacentHTML("afterbegin", html);

      // wait for layout to settle
      requestAnimationFrame(() => {
        const newHeight = this.element.scrollHeight;
        this.element.scrollTop = newHeight - prevHeight;
        // unlock after browser settles
        requestAnimationFrame(() => {
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
