require "httparty"

module MessageStatusCallbackNotifier
  module Request
    extend self

    DEFAULT_TIMEOUT = 60

    def get(url, headers = {})
      Retryable.call(tries: 2, on: Net::OpenTimeout) do
        HTTParty.get(
          url,
          timeout: DEFAULT_TIMEOUT,
          headers: headers
        )
      end
    end

    def post(url, payload, headers = {})
      Retryable.call(tries: 2, on: Net::OpenTimeout) do
        HTTParty.post(
          url,
          timeout: DEFAULT_TIMEOUT,
          headers: {
            "Content-Type" => "application/json"
          }.merge(headers),
          body: payload.to_json
        )
      end
    end
  end
end
