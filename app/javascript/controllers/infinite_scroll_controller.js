// import { Controller } from "@hotwired/stimulus";

// export default class extends Controller {
//   static values = {
//     customerId: Number,
//   };

//   static targets = ["container"];

//   connect() {
//     this.loading = false;
//     this.hasMore = true;
//     this.isAdjustingScroll = false;
//     this.oldestMessageId = null;
//     this.lastScrollTop = this.element.scrollTop;
//     this.boundOnScroll = this.onScroll.bind(this);
//     this.element.addEventListener("scroll", this.boundOnScroll);
//   }

//   disconnect() {
//     this.element.removeEventListener("scroll", this.boundOnScroll);
//   }

//   async onScroll() {
//     // ignore scrolls caused by our own adjustments
//     if (this.isAdjustingScroll) return;
//     const currentTop = this.element.scrollTop;
//     const scrollingUp = currentTop < this.lastScrollTop;
//     this.lastScrollTop = currentTop;
//     // ignore scroll-down completely
//     if (!scrollingUp) return;
//     // ignore if already loading or no more data
//     if (this.loading || !this.hasMore) return;
//     // only trigger very close to top
//     if (currentTop > 40) return;
//     this.loading = true;
//     await this.loadMore();
//     this.loading = false;
//   }

//   async loadMore() {
//     const firstMessage =
//       this.containerTarget.querySelector("[data-message-id]");

//     if (!firstMessage) {
//       this.hasMore = false;
//       return;
//     }

//     const beforeId = firstMessage.dataset.messageId.replace("msg-", "");
//     // STOP: we already tried loading before this id
//     if (this.oldestMessageId === beforeId) {
//       this.hasMore = false;
//       return;
//     }

//     this.oldestMessageId = beforeId;

//     const loader = document.getElementById(
//       `infinite-loading-${this.customerIdValue}`
//     );
//     loader?.classList.remove("hidden");
//     const prevHeight = this.element.scrollHeight;

//     try {
//       const response = await fetch(
//         `/customers/${this.customerIdValue}/messages?before_id=${beforeId}`
//       );

//       if (!response.ok) throw new Error("Request failed");
//       const html = await response.text();
//       if (!html.trim()) {
//         this.hasMore = false;
//         return;
//       }

//       // mark adjustment phase
//       this.isAdjustingScroll = true;
//       this.containerTarget.insertAdjacentHTML("afterbegin", html);

//       // wait for layout to settle
//       requestAnimationFrame(() => {
//         const newHeight = this.element.scrollHeight;
//         this.element.scrollTop = newHeight - prevHeight;
//         // unlock after browser settles
//         requestAnimationFrame(() => {
//           this.isAdjustingScroll = false;
//         });
//       });
//     } catch (e) {
//       console.error(e);
//     } finally {
//       loader?.classList.add("hidden");
//     }
//   }
// }



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
      const url = `/customers/${this.customerIdValue}/messages?page=${encodeURIComponent(this.nextPageValue)}`;

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
