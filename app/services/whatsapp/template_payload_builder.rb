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
              { type: "text", text: @params[:button_vars][btn["variable"]&.to_sym].to_s },
              # Here, the key 'text' is variable that we want to append in the url.
            ],
          }
        else
          nil
        end
      end.compact
    end
  end
end
