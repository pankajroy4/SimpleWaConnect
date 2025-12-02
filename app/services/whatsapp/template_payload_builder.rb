module Whatsapp
  class TemplatePayloadBuilder
    def initialize(template, params)
      @template = template
      @params = params
    end

    def self.build(template:, params:)
      new(template, params).build
    end

    def build
      {
        messaging_product: "whatsapp",
        # to: @params[:to],
        type: "template",
        template: {
          name: @template.name,
          language: { code: @params[:language_code] || @template.language_code },
          components: components,
        },
      }
    end

    def components
      comps = []

      # HEADER
      if header_needed?
        comps << header_component
      end

      # BODY
      if body_needed?
        comps << body_component
      elsif default_body_required?
        comps << default_body_component
      end

      # BUTTONS
      if buttons_needed?
        comps += button_components
      end

      comps
    end

    private

    # ========================= HEADER ===========================

    def header_needed?
      @template.has_header?
    end

    def header_component
      case @template.media_type
      when "text"
        {
          type: "header",
          parameters: @template.header_variables.map do |var|
            { type: "text", text: @params[:header_vars][var.to_sym].to_s }
          end,
        }
      when "image"
        {
          type: "header",
          parameters: [{ type: "image", image: { link: @params[:media_url] } }],
        }
      when "video"
        {
          type: "header",
          parameters: [{ type: "video", video: { link: @params[:media_url] } }],
        }
      when "document"
        {
          type: "header",
          parameters: [{
            type: "document",
            document: {
              link: @params[:media_url],
              filename: @params[:filename] || "document.pdf",
            }.compact,
          }],
        }
      else
        nil
      end
    end

    # ========================= BODY =============================

    def body_needed?
      @template.body_variables.present?
    end

    def body_component
      {
        type: "body",
        parameters: @template.body_variables.map do |var|
          {
            type: "text",
            text: @params[:body_vars][var.to_sym].to_s,
          }
        end,
      }
    end

    def default_body_required?
      @template.body_variables.blank?
    end

    def default_body_component
      {
        type: "body",
        parameters: [],
      }
    end

    # ========================= BUTTONS ===========================

    def buttons_needed?
      @template.button_variables.present?
    end

    # Need to fix it.
    def button_components
      @template.buttons.each_with_index.map do |btn, idx|
        case btn["type"]
        when "quick_reply"
          {
            type: "button",
            sub_type: "quick_reply",
            index: idx,
            parameters: [],
          }
        when "url"
          {
            type: "button",
            sub_type: "url",
            index: idx,
            parameters: [
              { type: "text", text: @params[:button_vars][btn["variable"]].to_s },
            ],
          }
        else
          nil
        end
      end.compact
    end
  end
end

# get payload:
# ================
# payload = {
#   messaging_product: "whatsapp",
#   to: params[:to],
#   type: "template",
#   template: {
#     name: template.name,
#     language: { code: params[:language_code] || template.language_code },
#     components: Whatsapp::TemplatePayloadBuilder.new(template: template, params: params).components
#   }
# }

# API CALL:
# ===================

# # Template message
# {
#   "message": {
#     "message_type": "template_message",
#     "recipients": [{"name": "Mohan", "mobile_no": "917436450082"}, {"name": "Mohan", "mobile_no":"918546230645"}],
#     "sender_phone_number": "7512460675", #(Optional) If want to send message from a particular no.
#     "template_name": "order_update",
#     "language_code": "en_US", (Optional)

#     "header_vars": {
#       "date": "23 Feb",
#     },

#     "body_vars": {
#       "name": "John",
#       "order_id": "ORD77891",
#     },

#     "button_vars": {
#       "tracking_code": "ZX9911",
#     },

#     "media_url": "https://...",
#     "filename": "receipt.pdf",
#   }
# }

# # Non-Template message

# {
#   "message": {
#     "message_type": "non_template_message",
#     "recipients": [{"name": "Mohan", "mobile_no": "917436450082"}, {"name": "Mohan", "mobile_no": "918546230645"}],
#     "sender_phone_number": "7512460675", #(Optional) - If want to send message from a particular no.
#     "body_text": "xyz...."
#   }
# }
