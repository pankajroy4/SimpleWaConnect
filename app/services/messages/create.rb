module Messages
  class Create
    MAX_TOTAL_RECIPIENTS = 100
    Result = Struct.new(:success?, :data, :error, :details, :http_status)

    def initialize(current_user, params, bulk_created, message_group)
      @user = current_user
      @account = current_user.account
      @params = params
      @bulk_created = bulk_created
      @message_group = message_group
      @queued_messages = []
      @errors = []
    end

    def self.call(current_user:, params:, bulk_created: false, message_group: nil)
      new(current_user, params, bulk_created, message_group).call
    end

    def call
      messages = @params
      unless messages.is_a?(Array) && messages.any?
        return failure("validation_error", ["messages must be a non-empty array"], 422)
      end

      batch_result = Messages::BatchCreateValidator.call(account: @account, messages: messages)

      validated = batch_result.validated_messages
      validator_errors = batch_result.errors

      validator_errors.each do |err|
        @errors << { input_index: err[:index], error: err[:errors] }
      end

      total_recipients = total_valid_recipients(validated)

      if total_recipients > MAX_TOTAL_RECIPIENTS
        return failure("recipient_limit_exceeded", { max_allowed: MAX_TOTAL_RECIPIENTS, total_requested: total_recipients }, 422)
      end

      message_group = get_message_group(validated)
      validated.each_with_index do |validated_params, index|
        process_single_message(validated_params, index, message_group)
      end

      if @queued_messages.empty?
        return failure("no_valid_messages", @errors, 422)
      end

      success({ queued_messages: @queued_messages, errors: @errors })
    end

    private

    def process_single_message(validated_params, input_index, message_group)
      recipient_errors = validated_params.delete(:recipient_errors) || []

      if validated_params[:recipients].empty?
        @errors << {
          input_index: input_index,
          errors: recipient_errors,
        }
        return
      end

      messages = []

      ActiveRecord::Base.transaction do
        validated_params[:recipients].each do |recipient|
          customer = Messages::FindOrCreateCustomer.call(
            account: @account,
            recipient: recipient,
            bulk_created: @bulk_created,
          )

          messages << Message.create!(
            account: @account,
            user: @user,
            customer: customer,
            bulk_created: @bulk_created,
            message_type: Message.message_types[validated_params[:message_type]],
            template: validated_params[:template],
            payload: validated_params.except(:template, :recipients, :sender_phone_number),
            direction: "outgoing",
            status: "queued",
            message_group: message_group,
          )
        end
      end

      messages.each do |message|
        Whatsapp::MessageDeliverJob.perform_later(message, message.id)
        @queued_messages << { message_id: message.id, recipient: message.customer.phone_number, status: "enqueued" }
      end

      if recipient_errors.any?
        @errors << {
          input_index: input_index,
          invalid_recipients: recipient_errors,
        }
      end
    rescue => e
      @errors << { input_index: input_index, error: e.message }
    end

    def get_message_group(messages)
      return @message_group if @message_group.present?
      if is_group_messages(messages)
        return "gr#{SecureRandom.hex(8)}"
      else
        nil
      end
    end

    def is_group_messages(messages)
      return true if messages.size > 1

      return true if messages.first[:recipients].size > 1

      false
    end

    def success(data)
      Result.new(true, data, nil, nil, 201)
    end

    def failure(error, details, http_status)
      Result.new(false, nil, error, details, http_status)
    end

    def total_valid_recipients(validated_messages)
      validated_messages.compact.sum { |msg| msg[:recipients].size }
    end
  end
end
