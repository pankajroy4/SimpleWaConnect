module Payloads
  class Structure
    Result = Struct.new(:success?, :data, :error, :details, :http_status)

    def self.call(params:)
      new(params).call
    end

    def initialize(params)
      @template_name = params[:template_name]
      @language_code = params[:language_code] || "en_US"
      @account = params[:account]
    end

    def call
      return failure("validation_error", ["template_name is required"], 422) unless @template_name.present?

      template = find_template
      return failure("not_found", ["Template not found"], 404) unless template

      success(wrap_messages(build_message_payload(template)))
    end

    private

    def find_template
      @account.templates.find_by(
        name: @template_name,
        language_code: @language_code,
        active: true,
      )
    end

    def wrap_messages(message_payload)
      {
        messages: [message_payload],
      }
    end

    def build_message_payload(template)
      payload = {
        message_type: "template_message",
        recipients: default_recipients,
        sender_phone_number: "",
        template_name: template.name,
        language_code: template.language_code,
      }

      if header_vars_required?(template)
        payload[:header_vars] = empty_vars(template.header_variables)
      end

      if template.body_variables.present?
        payload[:body_vars] = empty_vars(template.body_variables)
      end

      if template.button_variables.present?
        payload[:button_vars] = empty_vars(template.button_variables)
      end

      if media_required?(template)
        payload[:media_url] = ""
      end

      if filename_required?(template)
        payload[:filename] = ""
      end

      payload
    end

    def empty_vars(keys)
      keys.index_with { "" }
    end

    def default_recipients
      [{ name: "", mobile_no: "" }]
    end

    def header_vars_required?(template)
      template.has_header && template.header_variables.present?
    end

    def media_required?(template)
      template.media_type.present? && template.media_type != "text"
    end

    def filename_required?(template)
      template.media_type == "document"
    end

    def success(data)
      Result.new(true, data, nil, nil, 200)
    end

    def failure(error, details, http_status)
      Result.new(false, nil, error, details, http_status)
    end
  end
end
