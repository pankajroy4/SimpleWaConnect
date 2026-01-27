class MediaController < ApplicationController
  ALLOWED_MEDIA_HOSTS = ["lookaside.whatsapp.com", "mmg.whatsapp.net"].freeze
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

    uri = URI.parse(result.url)

    # 1. Validate scheme
    unless uri.is_a?(URI::HTTPS)
      Rails.logger.warn "Blocked non-HTTPS media request: #{uri}"
      return head :forbidden
    end

    # 2. Validate host against whitelist
    unless ALLOWED_MEDIA_HOSTS.include?(uri.host)
      Rails.logger.warn "Blocked media request to unapproved host: #{uri.host}"
      return head :forbidden
    end

    safe_filename = sanitize_filename(message.payload["filename"])

    send_stream(filename: safe_filename, disposition: "inline") do |stream|
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 15

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{account.whatsapp_credential.access_token}"

      http.request(request) do |response|
        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.error "Media download failed with status #{response.code}"
          stream.close
          break
        end

        response.read_body { |chunk| stream.write(chunk) }
      end

      stream.close
    end
  end

  private

  # Prevent path traversal or weird filenames
  def sanitize_filename(name)
    return "file" if name.blank?
    File.basename(name).gsub(/[^\w.\-]/, "_")
  end
end

# class MediaController < ApplicationController
#   include ActionController::Live

#   def show
#     message = Message.find(params[:id])
#     media_id = message.payload["media_id"]
#     account = message.account

#     result = Whatsapp::MediaFetcherService.fetch_download_url(
#       media_id: media_id,
#       account: account,
#     )

#     return head :not_found unless result.success?

#     send_stream(filename: message.payload["filename"] || "file",
#                 disposition: "inline") do |stream|
#       uri = URI(result.url)
#       http = Net::HTTP.new(uri.host, uri.port)
#       http.use_ssl = true

#       request = Net::HTTP::Get.new(uri)
#       request["Authorization"] = "Bearer #{account.whatsapp_credential.access_token}"

#       http.request(request) do |response|
#         unless response.is_a?(Net::HTTPSuccess)
#           stream.close
#           break
#         end

#         response.read_body do |chunk|
#           stream.write(chunk)
#         end
#       end

#       stream.close
#     end
#   end
# end
