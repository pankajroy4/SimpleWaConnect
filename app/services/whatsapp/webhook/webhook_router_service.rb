class Whatsapp::Webhook::WebhookRouterService
  def self.call(params)
    entries = params["entry"] || []

    entries.each do |entry|
      changes = entry["changes"] || []
      changes.each do |change|
        value = change["value"] || {}
        phone_number_id = value.dig('metadata', 'phone_number_id')

        if value["statuses"]
          Whatsapp::Webhook::StatusHandlerService.call(value["statuses"])
        elsif value["messages"]
          Whatsapp::Webhook::MessageHandlerService.call(value["messages"], phone_number_id, params)
        else
          Whatsapp::Webhook::OtherCallbacksService.call(value)
        end
      end
    end
  end
end
