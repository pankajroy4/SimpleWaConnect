module Whatsapp
  class MessageDeliveryService
    Result = Struct.new(:success?, :remote_id, :response, :error_text)

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
      remote_ids = []
      responses = []
      errors = []

      @message.customers.pluck(:phone_number).each do |to|
        payload = base_payload.merge(to: to)
        begin
          response = Whatsapp::WhatsappClient.send(payload, @account, phone_number_id)
          remote_ids << response[:remote_id]
          responses << response
        rescue => e
          errors << "#{e.class}: #{e.message}"
        end
        sleep(0.2)
      end

      return Result.new(true, remote_ids.first, responses, nil) if errors.empty?
      Result.new(false, remote_ids.first, responses, errors.join(" | "))
    end
  end
end
