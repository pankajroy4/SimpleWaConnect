RailsAdmin.config do |config|
  config.asset_source = :sprockets
  config.authenticate_with do
    warden.authenticate! scope: :user
  end

  config.current_user_method(&:current_user)

  config.authorize_with do
    redirect_to main_app.root_path unless current_user&.superadmin?
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end

  config.model "Account" do
    list do
      field :name
      field :platform
      field :whatsapp_phone_numbers
    end

    show do
      field :name
      field :platform
      field :whatsapp_phone_numbers
    end

    edit do
      field :name
      field :platform

      field :whatsapp_phone_numbers do
        nested_form allow_destroy: true
        associated_collection_cache_all false
      end
    end
  end

  config.model "Customer" do
    visible false
  end

  config.model "User" do
    list do
      field :email
      field :role
      field :account
      field :name
      field :callback_url
      field :callback_secret
      field :created_at
      field :updated_at
    end

    edit do
      field :email
      field :role
      field :account
      field :name
      field :callback_url
      field :callback_secret
      field :password
      field :password_confirmation
    end
  end

  config.model "Message" do
    list do
      field :account
      field :template
      field :user
      field :customer
      field :message_group
      field :bulk_created
      field :status
      field :message_type
      field :direction
      field :remote_id_meta
      field :error_text
      field :created_at
      field :updated_at
    end
  end
  
  config.model "WhatsappPhoneNumber" do
    edit do
      exclude_fields :account
    end

    show do
      exclude_fields :account
    end
  end

  config.model "WhatsappPhoneNumber" do
    edit do
      field :account
      field :phone_number_id_meta
      field :display_number
      field :status
      field :country_code
    end
  end
end
