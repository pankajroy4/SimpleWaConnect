class Messages::CreateValidator
  Result = Struct.new(:success?, :errors, :validated_params)

  def initialize(account, params, preloaded_template = nil, preloaded_sender = nil)
    @account = account
    @params = params
    @errors = []
    @recipient_errors = []

    @template = preloaded_template
    @sender = preloaded_sender
  end

  def self.call(account:, params:, template: nil, sender: nil)
    new(account, params, template, sender).call
  end

  def call
    validate_message_type
    validate_sender
    validate_recipients_individually
    validate_template_logic if @params[:recipients].any?

    # If message-level validation errors exist, message invalid
    if @errors.any?
      return Result.new(false, @errors, nil)
    end

    validated = sanitized_params.merge(recipient_errors: @recipient_errors)
    Result.new(true, nil, validated)
  end

  private

  def validate_message_type
    unless %w[template_message non_template_message].include?(@params[:message_type])
      @errors << "Invalid message_type"
    end
  end

  def template_message?
    @params[:message_type] == "template_message"
  end

  def validate_template_logic
    if template_message?
      load_template unless @template.present?
      validate_template_message
    else
      validate_non_template_message
    end
  end

  def validate_non_template_message
    case @params[:media_type].to_s.strip
    when nil, "", "text"
      validate_non_template_text
    when "image", "video", "audio", "document"
      validate_non_template_media
    else
      @errors << "Unsupported media type: #{@params[:media_type]}"
    end
  end

  def validate_non_template_text
    if @params[:body_text].blank?
      @errors << "body_text is required for non-template text message"
    end
  end

  def validate_non_template_media
    unless @params[:media_url].present? || @params[:media_id].present?
      @errors << "media_url is required for non-template media message"
      return
    end

    if @params[:media_type] == "document" && @params[:filename].blank?
      @errors << "filename is required for document messages"
    end
  end

  def validate_recipients_individually
    unless @params[:recipients].is_a?(Array) && @params[:recipients].any?
      @errors << "recipients must be a non-empty array"
      return
    end

    valid = []

    @params[:recipients].each do |r|
      r = r.symbolize_keys
      mobile = r[:mobile_no].to_s.gsub(/\D/, "")

      if mobile.blank?
        @recipient_errors << { recipient: r[:mobile_no], error: "mobile_no missing" }
        next
      end

      # Valid for template messages then skip 24-hour window check
      if template_message?
        valid << { name: r[:name] || "User", mobile_no: mobile }
        next
      end

      # Non-template: need customer and window validation
      customer = @account.customers.find_by(phone_number: mobile)
      if customer.nil?
        @recipient_errors << { recipient: mobile, error: "Customer not found for #{r[:mobile_no]}. Please send template message or Customer will auto creted when they reply to your business whatsApp." }

        next
      end

      last = customer.last_window_opened_at
      if last.nil? || last < 24.hours.ago
        @recipient_errors << { recipient: mobile, error: "24-hour session expired" }
        next
      end

      valid << { name: r[:name] || "User", mobile_no: mobile }
    end

    @params[:recipients] = valid
  end

  def load_template
    @template = if @params[:language_code]
        @account.templates.find_by(
          name: @params[:template_name],
          language_code: @params[:language_code],
        )
      else
        @account.templates.find_by(
          name: @params[:template_name],
          language_code: "en_US",
        )
      end

    @errors << "Template not found" unless @template
  end

  def validate_template_message
    return unless @template

    validate_template_variables
    validate_media_requirements
  end

  def validate_template_variables
    missing = [
      *missing_vars(:header_vars, @template.header_variables),
      *missing_vars(:body_vars, @template.body_variables),
      *missing_vars(:button_vars, @template.button_variables),
    ]

    @errors << "Missing template variables: #{missing.join(", ")}" if missing.any?
  end

  def missing_vars(param_key, required_vars)
    return [] if required_vars.blank?

    given_keys = (@params[param_key] || {}).keys.map(&:to_s).to_set
    missing = required_vars.reject { |k| given_keys.include?(k) }
    missing.map { |var| "#{param_key}.#{var}" }
  end

  def validate_media_requirements
    case @template.media_type
    when "video", "image"
      ensure_param(:media_url)
    when "document"
      ensure_param(:media_url)
      ensure_param(:filename)
    end
  end

  def ensure_param(key)
    @errors << "#{key} is required for #{@template.media_type} templates" unless @params[key].present?
  end

  # def validate_sender
  #   if @params[:sender_phone_number].present?
  #     @sender = @account.whatsapp_phone_numbers.active.find_by(display_number: @params[:sender_phone_number])
  #     @errors << "Sender phone number is invalid" unless @sender
  #   else
  #     @sender = @account.whatsapp_phone_numbers.active.first
  #     @errors << "No active WhatsApp phone numbers found" unless @sender
  #   end
  # end

  def validate_sender
    unless @sender
      @errors << "Sender phone number is invalid Or No active WhatsApp phone numbers found"
    end
  end

  def sanitized_params
    allowed = base_allowed_keys

    if template_message?
      allowed += %i[template_name language_code]
      allowed += template_allowed_variable_keys
      allowed += template_allowed_media_keys
    else
      allowed += non_template_allowed_keys
    end

    clean = @params.slice(*allowed)
    clean.merge(template: @template, sender_phone_number_id: @sender.phone_number_id)
  end

  def base_allowed_keys
    %i[message_type recipients sender_phone_number]
  end

  def non_template_allowed_keys
    %i[ body_text media_type media_url filename caption media_id ]
  end

  def template_allowed_variable_keys
    keys = []
    keys << :header_vars if @template.header_variables.present?
    keys << :body_vars if @template.body_variables.present?
    keys << :button_vars if @template.button_variables.present?
    keys
  end

  def template_allowed_media_keys
    case @template.media_type
    when "image", "video"
      [:media_url]
    when "document"
      [:media_url, :filename]
    else
      []
    end
  end
end
