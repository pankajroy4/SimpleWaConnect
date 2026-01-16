// app/javascript/controllers/chat_form_controller.js
import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  reset() {
    this.element.reset();

    const textarea = this.element.querySelector("textarea");
    if (textarea) textarea.style.height = "auto";

    const attachmentController = this.application.getControllerForElementAndIdentifier(
      this.element.closest('[data-controller~="attachment"]'),
      "attachment"
    );

    if (attachmentController) attachmentController.clear();
  }
}
