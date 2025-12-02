class Whatsapp::MessageDeliverJob < ApplicationJob
  class MessageDeliveryError < StandardError; end

  queue_as :default
  sidekiq_options retry: 0

  MESSAGE_JOB_LOGGER = Logger.new(Rails.root.join("log/message_jobs.log").to_s)
  MESSAGE_JOB_LOGGER.level = Logger::INFO

  sidekiq_retries_exhausted do |job, ex|
    message_id = job.dig("args", 0, "arguments").second
    message = Message.find_by(id: message_id)

    # gid_hash = job.dig("args", 0, "arguments").first
    # message = GlobalID::Locator.locate(gid_hash["_aj_globalid"]) rescue nil

    if message
      message.update!(status: "failed", error_text: ex.message)
      MESSAGE_JOB_LOGGER.error("FINAL FAILURE message_id=#{message.id} - #{ex.message}")
    else
      MESSAGE_JOB_LOGGER.error("FINAL FAILURE - could not resolve message from job args")
    end
  end

  def perform(message, message_id)
    MESSAGE_JOB_LOGGER.info("START message_id=#{message_id}")
    result = Whatsapp::MessageDeliveryService.call(message)

    wa_id = result.response&.first&.parsed_response&.dig("messages", 0, "id")
    response_json = result.response.map(&:parsed_response)

    if result.success?
      message.update!(
        status: "sent",
        remote_id: wa_id,
        response_json: response_json,
      )
      MESSAGE_JOB_LOGGER.info("SENT message_id=#{message_id}")
    else
      message.update!(
        status: "processing",
        error_text: result.error_text,
        response_json: response_json,
      )
      MESSAGE_JOB_LOGGER.error("ATTEMPT FAILED message_id=#{message_id} - #{result.error_text}")
      raise MessageDeliveryError, result.error_text
    end
  end
end
