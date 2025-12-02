module Messages
  class WebCreate
    Result = Struct.new(:success?, :message, :error)

    def self.call(customer:, user:, body_text:, attachment:)
      new(customer, user, body_text, attachment).call
    end

    def initialize(customer, user, body_text, attachment)
      @customer = customer
      @user = user
      @account = user.account
      @body_text = body_text
      @attachments = Array(attachment).reject(&:blank?)
    end

    def call
      messages_array = []
      phone_number_id, display_number = default_sender_number

      if @body_text.present?
        messages_array << {
          message_type: "non_template_message",
          sender_phone_number: display_number,
          recipients: [{
            name: @customer.name || "User",
            mobile_no: @customer.phone_number,
          }],
          body_text: @body_text,
        }
      end

      @attachments.each do |file|
        upload = Whatsapp::MediaUploadService.upload(
          file: file,
          account: @account,
          phone_number_id: phone_number_id,
        )

        unless upload.success?
          error = JSON.parse(upload.error)
          message = error&.dig("error", "message") || "An error occurred while uploading media!"
          return Result.new(false, nil, message)
        end

        media_type = case upload.content_type
          when /^image/ then "image"
          when /^video/ then "video"
          when /^audio/ then "audio"
          else "document"
          end

        messages_array << {
          message_type: "non_template_message",
          recipients: [{
            name: @customer.name || "User",
            mobile_no: @customer.phone_number,
          }],
          media_id: upload.media_id,
          media_type: media_type,
          filename: upload.filename,
        }
      end

      result = Messages::Create.call(
        current_user: @user,
        params: messages_array,
        bulk_created: false,
      )

      unless result.success?
        err = "#{result.error} - #{result.details&.dig(0, :errors, 0, :error)}"
        return Result.new(false, nil, err)
      end

      message_id = result.data[:queued_message_ids].last
      message = Message.find(message_id)

      Result.new(true, message, nil)
    end

    private

    def default_sender_number
      accnt = @account.whatsapp_phone_numbers.active.first
      [accnt.phone_number_id, accnt.display_number]
    end
  end
end
