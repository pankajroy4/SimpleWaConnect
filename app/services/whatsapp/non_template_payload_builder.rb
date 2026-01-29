module Whatsapp
  class NonTemplatePayloadBuilder
    def self.build(params:)
      new(params).build
    end

    def initialize(params)
      @params = params || {}
      @kind = @params[:kind].to_s
    end

    def build
      payload = case @kind
        when "text" then build_text
        when "media" then build_media
        when "cta_url" then build_cta_url
        when "list" then build_list
        when "buttons" then build_buttons
        else
          raise ArgumentError, "Unsupported message kind: #{@kind}"
        end

      base_payload.merge(payload)
    end

    private

    def base_payload
      { messaging_product: "whatsapp" }
    end

    # TEXT
    def build_text
      {
        type: "text",
        text: { body: @params[:text].to_s },
      }
    end

    # MEDIA (image, video, audio, document)
    def build_media
      media = @params[:media] || {}
      type = media[:type].to_s.strip

      raise ArgumentError, "Missing media type" if type.blank?

      {
        type: type,
        type.to_sym => media_object(type, media),
      }
    end

    def media_object(type, media)
      obj = {}
      obj[:link] = media[:url] if media[:url].present?
      obj[:id] = media[:id] if media[:id].present?
      obj[:caption] = media[:caption] if media[:caption].present?
      obj[:filename] = (media[:filename] || "document.pdf") if type == "document"
      obj
    end

    # CTA URL BUTTON
    def build_cta_url
      cta = @params[:cta] || {}

      {
        type: "interactive",
        interactive: {
          type: "cta_url",
          body: { text: cta[:body].to_s },
          action: {
            name: "cta_url",
            parameters: {
              display_text: cta[:button_text].to_s,
              url: cta[:url].to_s,
            },
          },
        },
      }
    end

    # LIST MESSAGE
    def build_list
      list = @params[:list] || {}

      interactive = {
        type: "list",
        body: { text: list[:body].to_s },
        action: {
          button: list[:button_text].to_s,
          sections: list[:sections] || [],
        },
        footer: list[:footer],
      }

      interactive[:header] = { type: "text", text: list[:header] } if list[:header].present?
      interactive[:footer] = { text: list[:footer] } if list[:footer].present?

      {
        type: "interactive",
        interactive: interactive,
      }
    end

    # REPLY BUTTONS MESSAGE
    def build_buttons
      data = @params[:buttons] || {}
      buttons = (data[:buttons] || []).first(3) # WhatsApp max = 3

      {
        type: "interactive",
        interactive: {
          type: "button",
          body: { text: data[:body].to_s },
          footer: data[:footer].present? ? { text: data[:footer] } : nil,
          action: {
            buttons: buttons.map do |btn|
              {
                type: "reply",
                reply: {
                  id: btn[:id].to_s,
                  title: btn[:title].to_s,
                },
              }
            end,
          },
        }.compact,
      }
    end
  end
end
