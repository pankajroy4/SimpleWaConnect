// app/javascript/controllers/customers_sidebar_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["item", "search"]

  connect() {
    this.openCustomerId = this.getOpenCustomerId()
    // request guard
    this.markReadInFlight = false
    this.lastMarkReadAt = 0

    // sound guard (prevents double sound on remove+prepend)
    this.lastSoundAt = 0

    this.applyActiveState()
    this.onBeforeStreamRender = this.onBeforeStreamRender.bind(this)
    document.addEventListener("turbo:before-stream-render", this.onBeforeStreamRender)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.onBeforeStreamRender)
  }

  getOpenCustomerId() {
    const frame = document.getElementById("chat_frame")
    const id = frame?.dataset?.openCustomerId
    return id ? Number(id) : null
  }

  filter(event) {
    const query = event.target.value.toLowerCase().trim()

    this.itemTargets.forEach(item => {
      const name = item.dataset.customerName?.toLowerCase() || ""
      const number = item.dataset.customerNumber || ""
      const matches = name.includes(query) || number.includes(query)
      item.classList.toggle("hidden", !matches)
    })
  }

  openCustomer(event) {
    const customerId = Number(event.currentTarget.dataset.customerId)
    if (!customerId) return

    this.openCustomerId = customerId
    window.OPEN_CUSTOMER_ID = customerId

    this.applyActiveState()
    this.hideBadge(customerId)

    const mobileSidebar = this.element.closest("[data-controller~='mobile-sidebar']")
    if (mobileSidebar) {
      const ctrl = this.application.getControllerForElementAndIdentifier(mobileSidebar, "mobile-sidebar")
      ctrl?.close()
    }
  }

  // Active + badge
  applyActiveState() {
    if (!this.openCustomerId) return

    this.element.querySelectorAll(".customers-sidebar-link").forEach(link => {
      link.classList.remove("bg-[rgb(var(--hover))]")
      link.querySelector(".customers-active-indicator")?.classList.add("opacity-0")
    })

    const activeLink = this.element.querySelector(`#customer-link-${this.openCustomerId}`)
    if (!activeLink) return

    activeLink.classList.add("bg-[rgb(var(--hover))]")
    activeLink.querySelector(".customers-active-indicator")?.classList.remove("opacity-0")

    // active chat should never show badge
    this.hideBadge(this.openCustomerId)
  }

  hideBadge(customerId) {
    const badge = this.element.querySelector(`.unread-badge[data-customer-id="${customerId}"]`)
    if (!badge) return

    badge.textContent = "0"
    badge.classList.add("hidden")
    badge.classList.remove("inline-flex")
  }

  // Turbo stream: maintain active & mark_read for active + Play sound only for NOT-open chats
  onBeforeStreamRender(event) {
    const stream = event.target
    if (!stream || stream.tagName !== "TURBO-STREAM") return

    const target = stream.getAttribute("target")
    const action = stream.getAttribute("action")
    if (!target || !action) return

    this.openCustomerId = this.getOpenCustomerId() || window.OPEN_CUSTOMER_ID || this.openCustomerId
    const messageContainerMatch = target.match(/^messages-container-(\d+)$/)
    const messageCustomerId = messageContainerMatch ? Number(messageContainerMatch[1]) : null

    const isMessageInsert =
      messageCustomerId && (action === "append" || action === "prepend")
    const badgeMatch = target.match(/^last_message_and_badge_(\d+)$/)
    const updatedCustomerId = badgeMatch ? Number(badgeMatch[1]) : null

    // detect prepend chats-container (move_to_top OR new chat)
    const isPrependToChats = action === "prepend" && target === "chats-container"

    // Find which customer id is being inserted during prepend
    let insertedCustomerId = null
    if (isPrependToChats) {
      const tpl = stream.querySelector("template")
      const rootEl = tpl?.content?.firstElementChild

      const row =
        rootEl?.id?.startsWith("customer_row_")
          ? rootEl
          : rootEl?.querySelector?.('[id^="customer_row_"]')

      if (row?.id) {
        const m = row.id.match(/^customer_row_(\d+)$/)
        if (m) insertedCustomerId = Number(m[1])
      }
    }

    // This must include OTHER chats too, not only open chat
    const affectsSidebar =
      badgeMatch ||                         // sidebar badge update
      isPrependToChats ||                   // reorder/prepend chat rows
      target === "chats-container" ||
      target === "chats-list" ||
      action === "remove" ||
      action === "replace" ||
      action === "update" ||
      isMessageInsert  // NEW: message inserted into messages-container-<id>

    if (!affectsSidebar) return

    const originalRender = event.detail.render
    event.detail.render = (streamElement) => {
      originalRender(streamElement)
      // 1) Keep open chat active + unread reset
      if (this.openCustomerId) {
        this.applyActiveState()

        const openChatWasUpdated =
          updatedCustomerId === this.openCustomerId ||
          insertedCustomerId === this.openCustomerId ||
          messageCustomerId === this.openCustomerId || 
          target === `last_message_and_badge_${this.openCustomerId}` ||
          target === `customer_row_${this.openCustomerId}`

        if (openChatWasUpdated) {
          this.markRead(this.openCustomerId, { force: true })
        }
      }

      // 2) Notification sound logic
      const shouldSoundForMessageInsert =
        isMessageInsert && messageCustomerId !== this.openCustomerId
      const shouldSoundForPrepend =
        insertedCustomerId && insertedCustomerId !== this.openCustomerId

      const shouldSoundForOtherChatUpdate =
        updatedCustomerId && updatedCustomerId !== this.openCustomerId

      const now = Date.now()
      const soundCooldown = 250

      if (
        (shouldSoundForMessageInsert || shouldSoundForPrepend || shouldSoundForOtherChatUpdate) &&
        now - this.lastSoundAt > soundCooldown
      ) {
        this.lastSoundAt = now
        this.playNotificationSound()
      }
    }
  }

  playNotificationSound() {
    const el = document.querySelector("[data-controller~='notification-sound']")
    if (!el) return
    const ctrl = this.application.getControllerForElementAndIdentifier(el, "notification-sound")
    ctrl?.play()
  }

  // mark_read API
  markRead(customerId, { force = false } = {}) {
    if (!customerId) return
    // never parallel calls
    if (this.markReadInFlight) return
    // throttle: only one call every 500ms
    const now = Date.now()
    if (now - this.lastMarkReadAt < 500) return
    // if not forced, and badge already hidden => skip
    if (!force) {
      const badge = this.element.querySelector(`.unread-badge[data-customer-id="${customerId}"]`)
      if (!badge || badge.classList.contains("hidden")) return
    }

    const token = document.querySelector("meta[name=csrf-token]")?.content
    if (!token) return

    this.markReadInFlight = true
    this.lastMarkReadAt = now

    fetch(`/chats/${customerId}/mark_read`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Accept": "application/json",
      },
    })
      .then(() => {
        this.hideBadge(customerId)
      })
      .catch(() => {})
      .finally(() => {
        this.markReadInFlight = false
      })
  }
}





