module Whatsapp
  class NonTemplatePayloadBuilder
    def initialize(params)
      @params = params
    end

    def self.build(params:)
      new(params).build
    end

    def build
      build_payload
    end

    private

    def build_payload
      media_type = @params[:media_type].to_s.strip
      media_url = @params[:media_url]
      media_id = @params[:media_id]
      caption = @params[:caption]
      text = @params[:body_text]

      case media_type
      when nil, "", "text"
        {
          messaging_product: "whatsapp",
          type: "text",
          text: { body: text },
        }
      when "image"
        {
          messaging_product: "whatsapp",
          type: "image",
          image: {
            link: media_url, # Needed when sending media Url from bulk.
            id: media_id,    # Needed when sending doc from UI.
            caption: caption,
          },
        }
      when "video"
        {
          messaging_product: "whatsapp",
          type: "video",
          video: {
            link: media_url,
            id: media_id,
            caption: caption,
          },
        }
      when "audio"
        {
          messaging_product: "whatsapp",
          type: "audio",
          audio: {
            link: media_url,
            id: media_id,
          },
        }
      when "document"
        {
          messaging_product: "whatsapp",
          type: "document",
          document: {
            link: media_url,
            id: media_id,
            filename: @params[:filename] || "document.pdf",
          },
        }
      else
        raise "Unsupported media_type: #{media_type}"
      end
    end
  end
end
