class MediaController < ApplicationController
  include ActionController::Live

  def show
    message = Message.find(params[:id])
    media_id = message.payload["media_id"]
    account = message.account

    result = Whatsapp::MediaFetcherService.fetch_download_url(
      media_id: media_id,
      account: account,
    )

    return head :not_found unless result.success?

    send_stream(filename: message.payload["filename"] || "file",
                disposition: "inline") do |stream|
      uri = URI(result.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{account.whatsapp_credential.access_token}"

      http.request(request) do |response|
        unless response.is_a?(Net::HTTPSuccess)
          stream.close
          break
        end

        response.read_body do |chunk|
          stream.write(chunk)
        end
      end

      stream.close
    end
  end
end
