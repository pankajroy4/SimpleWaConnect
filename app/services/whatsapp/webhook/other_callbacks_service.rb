class Whatsapp::Webhook::OtherCallbacksService
  def self.call(value)
    return # we do not need this service as we create templates from met dashbord using UI.
    new(value).call
  end

  def initialize(value)
    @value = value
  end

  def call
    if @value["message_template"]
      handle_template_event
    elsif @value["errors"]
      handle_error_event
    elsif @value["quality_update"]
      handle_quality_event
    else
      Rails.logger.info("Unhandled WhatsApp webhook: #{@value}")
    end
  end

  private

  def handle_template_event
    Rails.logger.info("Template event: #{@value}")
    # We can update Template model status here
  end

  def handle_error_event
    Rails.logger.error("WhatsApp error callback: #{@value["errors"]}")
  end

  def handle_quality_event
    Rails.logger.warn("Phone quality update: #{@value["quality_update"]}")
    # we can save into PhoneNumberQuality model if needed
  end
end
