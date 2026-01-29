// app/javascript/controllers/auto_scroll_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "scrollDownBtn", "unreadBadge"];

  connect() {
    this.unreadCount = 0;
    this.ignoreMutations = false;
    this.btnVisible = false;
    this.badgeVisible = false;
    this.hideBadge(true);
    this.scrollToBottom({ immediate: true });

    // Scroll listener (throttled)
    this.boundOnScroll = this.onScroll.bind(this);
    this.element.addEventListener("scroll", this.boundOnScroll, {
      passive: true,
    });

    // Outgoing submit => always bottom + clear unread
    document.addEventListener("turbo:submit-end", this.onTurboSubmitEnd);

    // Infinite scroll integration (ignore history prepend mutations)
    this.boundInfiniteAdjusting = () => {
      this.ignoreMutations = true;
    };

    this.boundInfiniteDone = () => {
      this.ignoreMutations = false;
    };

    this.element.addEventListener(
      "infinite-scroll:adjusting",
      this.boundInfiniteAdjusting
    );
    this.element.addEventListener(
      "infinite-scroll:done",
      this.boundInfiniteDone
    );

    this.observer = new MutationObserver(() => {
      if (this.ignoreMutations) return;

      // Just check the last message
      const last = this.containerTarget.lastElementChild;
      if (!last) return;

      // If last is wrapper, try inside
      const msgEl = last.dataset?.direction
        ? last
        : last.querySelector?.("[data-direction]");

      if (!msgEl) return;

      // Only incoming increments unread
      if (msgEl.dataset.direction !== "incoming") return;

      if (this.isNearBottom()) {
        this.scrollToBottom();
        this.resetUnread();
      } else {
        this.unreadCount += 1;
        this.showBadge();
        this.showScrollDownBtn();
      }
    });

    this.observer.observe(this.containerTarget, {
      childList: true,
      subtree: false,
    });

    this.updateScrollDownBtn();
  }

  disconnect() {
    this.observer?.disconnect();

    this.element.removeEventListener("scroll", this.boundOnScroll);
    document.removeEventListener("turbo:submit-end", this.onTurboSubmitEnd);

    this.element.removeEventListener(
      "infinite-scroll:adjusting",
      this.boundInfiniteAdjusting
    );
    this.element.removeEventListener(
      "infinite-scroll:done",
      this.boundInfiniteDone
    );

    cancelAnimationFrame(this.scrollRaf);
  }

  onTurboSubmitEnd = () => {
    this.scrollToBottom();
    this.resetUnread();
  };

  onScroll() {
    cancelAnimationFrame(this.scrollRaf);

    this.scrollRaf = requestAnimationFrame(() => {
      this.updateScrollDownBtn();
      if (this.unreadCount > 0 && this.isNearBottom()) {
        this.resetUnread();
      }
    });
  }

  scrollDownClicked() {
    this.scrollToBottom();
    this.resetUnread();
  }

  updateScrollDownBtn() {
    if (this.isNearBottom()) {
      this.hideScrollDownBtn();
    } else {
      this.showScrollDownBtn();
    }
  }

  showScrollDownBtn() {
    if (!this.hasScrollDownBtnTarget) return;
    if (this.btnVisible) return;

    this.scrollDownBtnTarget.classList.remove("hidden");
    this.btnVisible = true;
  }

  hideScrollDownBtn() {
    if (!this.hasScrollDownBtnTarget) return;
    if (!this.btnVisible) return;

    this.scrollDownBtnTarget.classList.add("hidden");
    this.btnVisible = false;
  }

  resetUnread() {
    this.unreadCount = 0;
    this.hideBadge();
  }

  showBadge() {
    if (!this.hasUnreadBadgeTarget) return;

    const value = this.unreadCount > 99 ? "99+" : String(this.unreadCount);

    if (this.unreadBadgeTarget.textContent !== value) {
      this.unreadBadgeTarget.textContent = value;
    }

    if (!this.badgeVisible) {
      this.unreadBadgeTarget.classList.remove("hidden");
      this.unreadBadgeTarget.classList.add("inline-flex");
      this.badgeVisible = true;
    }
  }

  hideBadge(force = false) {
    if (!this.hasUnreadBadgeTarget) return;

    if (
      !force &&
      !this.badgeVisible &&
      this.unreadBadgeTarget.classList.contains("hidden")
    )
      return;

    this.unreadBadgeTarget.textContent = "";
    this.unreadBadgeTarget.classList.add("hidden");
    this.unreadBadgeTarget.classList.remove("inline-flex");
    this.badgeVisible = false;
  }

  scrollToBottom({ immediate = false } = {}) {
    const el = this.element;
    const top = el.scrollHeight - el.clientHeight;
    if (top <= 0) return;

    if (immediate) {
      el.scrollTop = el.scrollHeight;
      return;
    }
    try {
      el.scrollTo({ top: el.scrollHeight, behavior: "smooth" });
    } catch (_e) {
      el.scrollTop = el.scrollHeight;
    }
  }

  isNearBottom() {
    const el = this.element;
    const threshold = 600;
    return el.scrollHeight - el.scrollTop - el.clientHeight < threshold;
  }
}
