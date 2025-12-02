class Whatsapp::Webhook::StatusHandlerService
  def self.call(status_list)
    status_list.each do |status|
      remote_id = status["id"]
      state = status["status"]

      message = Message.find_by(remote_id: remote_id)
      next unless message

      case state
      when "delivered"
        message.update(status: "delivered")
      when "read"
        message.update(status: "read")
      when "failed"
        error_message = status.dig("errors", 0, "message")
        error_title = status.dig("errors", 0, "title")
        error_details = status.dig("errors", 0, "error_data", "details")

        error_text = [error_title, error_message, error_details].compact.join(" - ")

        message.update(status: "failed", error_text: error_text.presence || "Unknown WA error")
      end
    end
  end
end
