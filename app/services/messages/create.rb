module Messages
  class Create
    Result = Struct.new(:success?, :data, :error, :details, :http_status)

    def initialize(current_user, params, bulk_created)
      @user = current_user
      @account = current_user.account
      @params = params
      @bulk_created = bulk_created
      @queued_ids = []
      @errors = []
    end

    def self.call(current_user:, params:, bulk_created: false)
      new(current_user, params, bulk_created).call
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

      validated.each_with_index do |validated_params, index|
        next if validated_params.nil?
        process_single_message(validated_params, index)
      end

      if @queued_ids.empty?
        return failure("no_valid_messages", @errors, 422)
      end

      success({ queued_message_ids: @queued_ids, errors: @errors })
    end

    private

    def process_single_message(validated_params, input_index)
      recipient_errors = validated_params.delete(:recipient_errors) || []

      if validated_params[:recipients].empty?
        @errors << {
          input_index: input_index,
          errors: recipient_errors,
        }
        return
      end

      ActiveRecord::Base.transaction do
        message = Message.create!(
          account: @account,
          user: @user,
          bulk_created: @bulk_created,
          message_type: Message.message_types[validated_params[:message_type]],
          template: validated_params[:template],
          payload: validated_params.except(:template, :recipients, :sender_phone_number),
          direction: "outgoing",
          status: "queued",
        )

        Messages::FindOrCreateCustomer.call(
          account: @account,
          message: message,
          recipients: validated_params[:recipients],
          bulk_created: @bulk_created,
        )

        Whatsapp::MessageDeliverJob.perform_later(message, message.id)

        @queued_ids << message.id

        if recipient_errors.any?
          @errors << {
            input_index: input_index,
            invalid_recipients: recipient_errors,
          }
        end
      end
    rescue => e
      @errors << { input_index: input_index, error: e.message }
    end

    def success(data)
      Result.new(true, data, nil, nil, 201)
    end

    def failure(error, details, http_status)
      Result.new(false, nil, error, details, http_status)
    end
  end
end
