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
      @template.button_variables.present? || @template.buttons.present?
    end

    def button_components
      Array(@template.buttons).each_with_index.map do |btn, idx|
        btn_type = btn["type"].to_s

        case btn_type
        when "quick_reply" # QUICK REPLY (custom / preconfigured -> same at payload level)
          {
            type: "button",
            sub_type: "quick_reply",
            index: idx,
            parameters: [],
          }
        when "url" # URL BUTTON (STATIC / DYNAMIC) - Only dynamic URL takes parameters
          variable_key = btn["variable"]&.to_sym
          url_param_text = variable_key.present? ? @params.dig(:button_vars, variable_key).to_s : nil

          {
            type: "button",
            sub_type: "url",
            index: idx,
            parameters: url_param_text.present? ? [{ type: "text", text: url_param_text }] : [],
          # Here, the key 'text' is variable that we want to append in the url.
          }
        when "call_on_phone" # PHONE NUMBER BUTTON (static in template)
          {
            type: "button",
            sub_type: "voice_call",
            index: idx,
            parameters: [],
          }
        when "copy_code", "COPY_CODE"
          variable_key = btn["variable"]&.to_sym || :coupon_code
          code_value = @params.dig(:button_vars, variable_key).to_s

          if code_value.blank?
            next nil
          end

          {
            type: "button",
            sub_type: "copy_code",
            index: idx,
            parameters: [
              {
                type: "coupon_code",
                coupon_code: code_value,
              },
            ],
          }
        when "call_on_whatsapp" # CALL ON WHATSAPP - In Meta dashboard this is static
          {
            type: "button",
            sub_type: "voice_call",
            index: idx,
            parameters: [],
          }
        else
          Rails.logger.warn(
            "Unsupported WhatsApp template button type: #{btn_type}. " \
            "template_id=#{@template.id} template_name=#{@template.name} button=#{btn.inspect}"
          )
          nil
        end
      end.compact
    end
  end
end
