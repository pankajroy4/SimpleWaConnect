module MessageStatusCallbackNotifier
  module Client
    extend self

    def notify(message)
      raw_response = MessageStatusCallbackNotifier::Api::Notify.call(message)
      Response::Notify.new(raw_response)
    end
  end
end
