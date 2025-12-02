class Whatsapp::ProcessWebhookJob < ApplicationJob
  queue_as :default

  def perform(raw_payload)
    params = JSON.parse(raw_payload) rescue {}
    Whatsapp::Webhook::WebhookRouterService.call(params)
  end
end
