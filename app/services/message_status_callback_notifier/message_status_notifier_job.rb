class MessageStatusCallbackNotifier::MessageStatusNotifierJob < ApplicationJob
  class MessageNotifierError < StandardError; end

  queue_as :default
  retry_on MessageNotifierError, attempts: 2

  discard_on MessageNotifierError

  def perform(message_id)
    message = Message.find(message_id)
    # return if message.user.callback_url.blank?

    response = MessageStatusCallbackNotifier::Client.notify(message)
    unless response.success?
      raise MessageNotifierError, "Error in notifier"
    end
  end
end
