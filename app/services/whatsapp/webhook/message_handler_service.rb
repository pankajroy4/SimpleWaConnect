# app/services/whatsapp/webhook/message_handler_service.rb
module Whatsapp
  module Webhook
    class MessageHandlerService
      def initialize(messages, phone_number_id, params)
        @messages = messages
        @phone_number_id = phone_number_id
        @params = params
      end

      def self.call(messages, phone_number_id, params)
        new(messages, phone_number_id, params).call
      end

      def call
        @messages.each do |msg|
          process_message(msg)
        end
      end

      private

      def process_message(msg)
        in_txn do
          update_customer_window(msg)

          @account, @customer = resolve_account_and_customer(msg)
          unless @account && @customer
            Rails.logger.error("Account or customer not found for phone_number_id=#{@phone_number_id}")
            next
          end

          dispatch_by_type(msg)
        end
      end

      def dispatch_by_type(msg)
        case msg["type"]
        when "text" then handle_text(msg)
        when "image" then handle_media(msg, :image)
        when "document" then handle_media(msg, :document)
        when "video" then handle_media(msg, :video)
        when "audio" then handle_media(msg, :audio)
        when "interactive" then handle_interactive(msg)
        when "location" then handle_location(msg)
        when "contacts" then handle_contact(msg)
        else
          Rails.logger.info("Unhandled WA message type: #{msg["type"]}")
        end
      end

      def in_txn(&block)
        ActiveRecord::Base.transaction { block.call }
      end

      def normalize_phone(phone)
        phone.to_s.gsub(/\D/, "")
      end

      def resolve_account_and_customer(msg)
        phone = normalize_phone(msg["from"])
        account = WhatsappPhoneNumber.find_by(phone_number_id: @phone_number_id)&.account
        return [nil, nil] unless account

        customer = Customer.find_or_create_by!(account_id: account.id, phone_number: phone)
        [account, customer]
      end

      def update_customer_window(msg)
        phone = normalize_phone(msg["from"])
        account = WhatsappPhoneNumber.find_by(phone_number_id: @phone_number_id)&.account
        return unless account

        customer = Customer.find_or_create_by!(account_id: account.id, phone_number: phone)
        customer.update_columns(last_window_opened_at: Time.zone.now, bulk_created: false)
      end

      def create_incoming_message!(payload:, remote_id:)
        Message.create!(
          account: @account,
          message_type: Message.message_types[:non_template_message],
          payload: payload,
          incoming_webhook_payload: @params,
          bulk_created: false,
          direction: "incoming",
          status: "read",
          remote_id: remote_id,
        ).tap { |m| m.customers << @customer }
      end

      def handle_text(msg)
        create_incoming_message!(
          payload: { "body_text" => msg.dig("text", "body") },
          remote_id: msg["id"],
        )
      end

      def handle_media(msg, type)
        data = msg[type.to_s]
        media_id = data["id"]

        payload = {
          "media_type" => type.to_s,
          "media_id" => media_id,
          "filename" => resolve_filename(type, data),
        }
        payload["caption"] = data["caption"] if data["caption"]

        create_incoming_message!(
          payload: payload,
          remote_id: msg["id"],
        )
      end

      def resolve_filename(type, data)
        case type
        when :image, :video
          "whatsapp_media_#{data["id"]}"
        when :audio
          "audio_#{data["id"]}"
        when :document
          data["filename"] || "file_#{data["id"]}"
        end
      end

      def handle_interactive(msg)
        title = msg.dig("interactive", "button_reply", "title") ||
                msg.dig("interactive", "list_reply", "title")

        handle_text(
          "text" => { "body" => title },
          "from" => msg["from"],
          "id" => msg["id"],
        )
      end

      def handle_location(msg)
        loc = msg["location"] || return

        payload = {
          "media_type" => "location",
          "latitude" => loc["latitude"],
          "longitude" => loc["longitude"],
          "address" => loc["address"],
        }

        create_incoming_message!(
          payload: payload,
          remote_id: msg["id"],
        )
      end

      def handle_contact(msg)
        contact = msg.dig("contacts", 0) || return

        payload = {
          "media_type" => "contact",
          "contact" => contact,
        }

        create_incoming_message!(
          payload: payload,
          remote_id: msg["id"],
        )
      end
    end
  end
end


# app/services/whatsapp/webhook/message_handler_service.rb
# module Whatsapp
#   module Webhook
#     class MessageHandlerService
#       def initialize(messages, phone_number_id, params)
#         @messages = messages
#         @phone_number_id = phone_number_id
#         @params = params
#       end

#       def self.call(messages, phone_number_id, params)
#         new(messages, phone_number_id, params).call
#       end

#       def call
#         @messages.each do |msg|
#           update_customer_window(msg)

#           @account, @customer = resolve_account_and_customer(msg)
#           unless @account && @customer
#             Rails.logger.error("Account or customer not found for phone_number_id=#{@phone_number_id}")
#             next
#           end

#           dispatch(msg)
#         end
#       end

#       private

#       def dispatch(msg)
#         case msg["type"]
#         when "text" then in_txn { handle_text(msg) }
#         when "image" then in_txn { handle_media(msg, :image) }
#         when "document" then in_txn { handle_media(msg, :document) }
#         when "video" then in_txn { handle_media(msg, :video) }
#         when "audio" then in_txn { handle_media(msg, :audio) }
#         when "interactive" then in_txn { handle_interactive(msg) }
#         when "location" then in_txn { handle_location(msg) }
#         when "contacts" then in_txn { handle_contact(msg) }
#         else
#           Rails.logger.info("Unhandled WA message type: #{msg["type"]}")
#         end
#       end

#       def in_txn(&block)
#         ActiveRecord::Base.transaction { block.call }
#       end

#       def normalize_phone(phone)
#         phone.to_s.gsub(/\D/, "")
#       end

#       def resolve_account_and_customer(msg)
#         phone = normalize_phone(msg["from"])
#         account = WhatsappPhoneNumber.find_by(phone_number_id: @phone_number_id)&.account
#         return [nil, nil] unless account

#         customer = Customer.find_or_create_by!(account_id: account.id, phone_number: phone)
#         [account, customer]
#       end

#       def update_customer_window(msg)
#         phone = normalize_phone(msg["from"])
#         account = WhatsappPhoneNumber.find_by(phone_number_id: @phone_number_id)&.account
#         return unless account

#         customer = Customer.find_or_create_by!(account_id: account.id, phone_number: phone)
#         customer.update_columns(last_window_opened_at: Time.zone.now)
#       end

#       def create_incoming_message!(payload:, remote_id:)
#         Message.create!(
#           account: @account,
#           message_type: Message.message_types[:non_template_message],
#           payload: payload,
#           incoming_webhook_payload: @params,
#           bulk_created: false,
#           direction: "incoming",
#           status: "read",
#           remote_id: remote_id,
#         ).tap { |m| m.customers << @customer }
#       end

#       def handle_text(msg)
#         create_incoming_message!(
#           payload: { "body_text" => msg.dig("text", "body") },
#           remote_id: msg["id"],
#         )
#       end

#       def handle_media(msg, type)
#         data = msg[type.to_s]
#         media_id = data["id"]

#         payload = {
#           "media_type" => type.to_s,
#           "media_id" => media_id,
#           "filename" => resolve_filename(type, data),
#         }
#         payload["caption"] = data["caption"] if data["caption"]

#         create_incoming_message!(
#           payload: payload,
#           remote_id: msg["id"],
#         )
#       end

#       def resolve_filename(type, data)
#         case type
#         when :image, :video
#           "whatsapp_media_#{data["id"]}"
#         when :audio
#           "audio_#{data["id"]}"
#         when :document
#           data["filename"] || "file_#{data["id"]}"
#         end
#       end

#       def handle_interactive(msg)
#         title = msg.dig("interactive", "button_reply", "title") ||
#                 msg.dig("interactive", "list_reply", "title")

#         handle_text(
#           "text" => { "body" => title },
#           "from" => msg["from"],
#           "id" => msg["id"],
#         )
#       end

#       def handle_location(msg)
#         loc = msg["location"] || return

#         payload = {
#           "media_type" => "location",
#           "latitude" => loc["latitude"],
#           "longitude" => loc["longitude"],
#           "address" => loc["address"],
#         }

#         create_incoming_message!(
#           payload: payload,
#           remote_id: msg["id"],
#         )
#       end

#       def handle_contact(msg)
#         contact = msg.dig("contacts", 0) || return

#         payload = {
#           "media_type" => "contact",
#           "contact" => contact,
#         }

#         create_incoming_message!(
#           payload: payload,
#           remote_id: msg["id"],
#         )
#       end
#     end
#   end
# end
