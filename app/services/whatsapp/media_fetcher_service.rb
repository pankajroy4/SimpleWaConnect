# app/services/whatsapp/media_fetcher_service.rb
require "httparty"

module Whatsapp
  class MediaFetcherService
    Result = Struct.new(:success?, :url, :content_type, :filename, :error)

    def self.fetch_download_url(media_id:, account:)
      return Result.new(false, nil, nil, nil, "missing_media_id") unless media_id
      token = account&.whatsapp_credential&.access_token
      return Result.new(false, nil, nil, nil, "missing_token") unless token

      begin
        meta_resp = HTTParty.get("https://graph.facebook.com/v23.0/#{media_id}",
                                headers: { "Authorization" => "Bearer #{token}" },
                                timeout: 10)

        unless meta_resp.success?
          return Result.new(false, nil, nil, nil, "meta_fetch_failed: #{meta_resp.code}")
        end

        download_url = meta_resp.parsed_response.dig("url")
        return Result.new(false, nil, nil, nil, "no_download_url") unless download_url

        # Optional HEAD to detect content-type/filename
        head = HTTParty.head(download_url, timeout: 10) rescue nil
        content_type = head&.headers&.[]("content-type") || meta_resp.parsed_response.dig("mime_type")
        filename = head&.headers&.[]("content-disposition")&.match(/filename="?([^\";]+)"/)&.captures&.first
        filename ||= "whatsapp_media_#{media_id}"

        Result.new(true, download_url, content_type, filename, nil)
      rescue => e
        Result.new(false, nil, nil, nil, e.message)
      end
    end
  end
end
