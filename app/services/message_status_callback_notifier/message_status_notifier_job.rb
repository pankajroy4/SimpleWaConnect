class MessageStatusCallbackNotifier::MessageStatusNotifierJob < ApplicationJob
  queue_as :default

  # TODO: need to retry for 3 ties if fails then do not retry anymore.
  def perform(message_id)
    message = Message.find(message_id)
    return if message.user.callback_url.blank?

    response = MessageStatusCallbackNotifier::Client.notify(message)
    unless response.success?
      retry_job wait: 5.minutes, queue: :default
    end
  end
end
