require "httparty"
require "multipart/post"

module Whatsapp
  class MediaUploadService
    Result = Struct.new(:success?, :media_id, :content_type, :filename, :error)

    def self.upload(file:, account:, phone_number_id:)
      new(file, account, phone_number_id).upload
    end

    def initialize(file, account, phone_number_id)
      @file = file
      @account = account
      @phone_number_id = phone_number_id
    end

    def upload
      begin
        url = "https://graph.facebook.com/v23.0/#{@phone_number_id}/media"

        mime = normalized_content_type(@file)

        payload = {
          "messaging_product" => "whatsapp",
          "type" => mime,
          "file" => UploadIO.new(@file.tempfile, mime, @file.original_filename),
        }

        response = HTTParty.post(
          url,
          headers: { "Authorization" => "Bearer #{@account.whatsapp_credential.access_token}" },
          body: payload,
          multipart: true,
        )

        if response.code.in?([200, 201])
          return Result.new(true, response["id"], mime, @file.original_filename, nil)
        else
          return Result.new(false, nil, nil, nil, response.body)
        end
      rescue => e
        return Result.new(false, nil, nil, nil, e.message)
      end
    end

    private

    def normalized_content_type(file)
      ct = file.content_type

      # WhatsApp rejects `application/mp4` → correct it
      return "video/mp4" if ct == "application/mp4"
      return "audio/mpeg" if ct == "audio/mp3"

      ct
    end
  end
end
