class Messages::BatchCreateValidator
  Result = Struct.new(:success?, :errors, :validated_messages)

  def self.call(account:, messages:)
    new(account, messages).call
  end

  def initialize(account, messages)
    @account = account
    @messages = messages
    @errors = []
    @validated = []

    preload_senders
    preload_templates
  end

  def call
    @messages.each_with_index do |secure_params, idx|
      msg = secure_params.to_h.deep_symbolize_keys
      template = lookup_template(msg)
      sender = lookup_sender(msg)

      validation = Messages::CreateValidator.call(
        account: @account,
        params: msg,
        template: template,
        sender: sender,
      )

      if validation.success?
        @validated << validation.validated_params
      else
        err = validation.errors || validation.validated_params&.dig(:recipient_errors, 0, :error)
        @errors << { index: idx, errors: err }
        @validated << nil
      end
    end

    Result.new(true, @errors, @validated)
  end

  private

  def preload_senders
    @senders = @account.whatsapp_phone_numbers.active.index_by(&:display_number)
  end

  def lookup_sender(params)
    phone = params[:sender_phone_number]

    if phone.present?
      return @senders[phone]    # return nil if invalid
    end
    @senders.values.first
  end

  def preload_templates
    needed = @messages.map do |msg|
      h = msg.to_h.symbolize_keys
      next nil unless h[:template_name]
      [h[:template_name], h[:language_code] || "en_US"]
    end.compact.uniq

    # One DB query
    @templates = @account.templates
      .where(needed.map { |name, lang| { name: name, language_code: lang } }.reduce(:or))
      .index_by { |t| "#{t.name}:#{t.language_code}" }
  end

  def preload_templates
    needed = @messages.map do |msg|
      h = msg.to_h.symbolize_keys
      next nil if h[:message_type] == "non_template_message"
      next nil unless h[:template_name]
      [h[:template_name], h[:language_code] || "en_US"]
    end.compact.uniq

    if needed.empty?
      @templates = {}
      return
    end

    # One DB query
    @templates = @account.templates
      .where(needed.map { |name, lang| { name: name, language_code: lang } }.reduce(:or))
      .index_by { |t| "#{t.name}:#{t.language_code}" }
  end

  def lookup_template(params)
    return nil unless params[:template_name]
    key = "#{params[:template_name]}:#{params[:language_code] || "en_US"}"
    @templates[key]
  end
end
