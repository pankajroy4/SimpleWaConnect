class Whatsapp::MessageDeliverJob < ApplicationJob
  class MessageDeliveryError < StandardError; end

  queue_as :default
  retry_on MessageDeliveryError, attempts: 1

  MESSAGE_JOB_LOGGER = Logger.new(Rails.root.join("log/message_jobs.log"))
  MESSAGE_JOB_LOGGER.level = Logger::INFO

  # Final failure
  discard_on MessageDeliveryError do |job, error|
    message = job.arguments.first

    if message
      message.update!(status: "failed", error_text: error.message)
      MessageStatusCallbackNotifier::MessageStatusNotifierJob.perform_later(message.id) if message.bulk_created?
      MESSAGE_JOB_LOGGER.error("FINAL FAILURE message_id=#{message.id} - #{error.message}")
    else
      MESSAGE_JOB_LOGGER.error("FINAL FAILURE - message not available in job arguments")
    end
  end

  def perform(message, message_id)
    MESSAGE_JOB_LOGGER.info("START message_id=#{message_id}")

    message_response = Whatsapp::MessageDeliveryService.call(message)

    if message_response.success?
      message.update!(
        status: message_response.message_status || "accepted",
        remote_id_meta: message_response.wa_message_id,
        response_json: message_response.success_response,
      )
      MESSAGE_JOB_LOGGER.info("SENT message_id=#{message.id}")
    else
      if message_response.internal_server_error?
        message.update!(
          status: "processing",
          error_text: message_response.error_message,
          response_json: message_response.raw_response,
        )

        MESSAGE_JOB_LOGGER.error("ATTEMPT FAILED message_id=#{message.id} - #{message_response.error_message}")
        raise MessageDeliveryError, message_response.error_message
      else
        message.update!(
          status: "failed",
          error_text: message_response.error_message,
          response_json: message_response.raw_response,
        )

        MessageStatusCallbackNotifier::MessageStatusNotifierJob.perform_later(message.id) if message.bulk_created?

        MESSAGE_JOB_LOGGER.error("ATTEMPT FAILED message_id=#{message.id} - #{message_response.error_message}")
      end
    end
  end
end
