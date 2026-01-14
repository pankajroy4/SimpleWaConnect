import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { customerId: Number }

  connect() {
    this.onBeforeStreamRender = this.onBeforeStreamRender.bind(this)
    document.addEventListener("turbo:before-stream-render", this.onBeforeStreamRender)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.onBeforeStreamRender)
  }

  onBeforeStreamRender(event) {
    const stream = event.target
    if (!stream || stream.tagName !== "TURBO-STREAM") return

    const action = stream.getAttribute("action")
    const target = stream.getAttribute("target")

    // We only care about new messages appended in currently open chat list
    if (action !== "append") return
    if (target !== `messages-container-${this.customerIdValue}`) return

    const originalRender = event.detail.render
    event.detail.render = (streamElement) => {
      originalRender(streamElement)

      // find last message in open chat list
      const list = document.getElementById(`messages-container-${this.customerIdValue}`)
      const lastMsg = list?.querySelector("[data-message-id]:last-child")
        console.log("lastMsg", lastMsg)
      if (!lastMsg) return

      const direction = lastMsg.dataset.direction
      console.log("direction", direction)

      // get sound controller
      const soundEl = document.querySelector("[data-controller~='chat-sound']")
      if (!soundEl) return
      const ctrl = this.application.getControllerForElementAndIdentifier(soundEl, "chat-sound")

      if (direction === "outgoing") ctrl?.send()
      if (direction === "incoming") ctrl?.receive()
    }
  }
}
