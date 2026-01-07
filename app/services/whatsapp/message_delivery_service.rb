module Whatsapp
  class MessageDeliveryService
    def self.call(message)
      new(message).call
    end

    def initialize(message)
      @message = message
      @account = message.account
    end

    def call
      begin
        # raise "test Error message"  # just for testing
        return non_template_flow unless template_message?
        template_flow
      rescue => e
        Result.new(false, nil, [], e.message)
      end
    end

    private

    def template_message?
      @message.template.present? && @message.template_message?
    end

    def template_flow
      template = @message.template
      params = @message.payload.deep_symbolize_keys
      phone_number_id = params[:sender_phone_number_id]

      base_payload = Whatsapp::TemplatePayloadBuilder.build(template: template, params: params)
      send_to_recipients(base_payload, phone_number_id)
    end

    def non_template_flow
      params = @message.payload.deep_symbolize_keys
      phone_number_id = params[:sender_phone_number_id]
      base_payload = Whatsapp::NonTemplatePayloadBuilder.build(params: params)

      send_to_recipients(base_payload, phone_number_id)
    end

    def send_to_recipients(base_payload, phone_number_id)
      error = nil
      response = nil
      to = @message.customer.phone_number

      payload = base_payload.merge(to: to)
      begin
        response = Whatsapp::WhatsappClient.send(payload, @account, phone_number_id)
        return Whatsapp::MessageResponse.new(response)
      rescue => e
        return Whatsapp::MessageResponse.new({error: {
          message: e.message,
          code: 500
        }})
      end
    end
  end
end