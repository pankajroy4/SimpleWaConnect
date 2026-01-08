# Create Account and Whatsapp Phone Number record
Account.create!(
  name: "Demo Account",
  platform: "simpledairy",
  whatsapp_phone_numbers_attributes: [ # Nested attributes for phone numbers
    {
      phone_number_id_meta: "809219032271174",
      display_number: "5551811580",  # Whatsapp account mobile display number - without country code
      status: :active,
      country_code: "1",
    },
  ],
)

WhatsappPhoneNumber.create(account: Account.first, phone_number_id_meta: "809219032271174", display_number: "5551811580", status: 0, country_code: "1")

User.create!(
  email: "test@gmail.com",
  name: "Mohan",
  password: "111111",
  password_confirmation: "111111",
  account: Account.last,
  role: "admin",
)

User.create!(
  email: "superadmin@gmail.com",
  password: "111111",
  name: "SuperAdmin",
  password_confirmation: "111111",
  role: "superadmin",
)

# Create Templates record
Template.create!(
  account: Account.first,
  name: "hello_world",
  language_code: "en_US",
  has_header: false,
  media_type: "text",       # no media needed
  header_variables: [],
  body_variables: [],
  button_variables: [],
  active: true,
)

Template.create!(
  account: Account.first,
  name: "vid_template",
  language_code: "en_US",
  has_header: true,
  media_type: "video",
  header_variables: [],
  body_variables: [],
  button_variables: [],
  active: true,
)

Template.create!(
  account: Account.first,
  name: "document_template",
  language_code: "en_US",
  has_header: true,
  media_type: "document",
  header_variables: [],
  body_variables: ["amount", "location", "doc_type"],
  button_variables: [],
  active: true,
)

Template.create!(
  account: Account.first,
  name: "invoice_template",
  language_code: "en_US",
  has_header: true,
  media_type: "document",
  header_variables: [],
  body_variables: ["user_name"],
  button_variables: [],
  active: true,
)

Template.create!(
  account: Account.first,
  name: "text_template",
  language_code: "en_US",
  has_header: true,
  media_type: "text",
  header_variables: ["brand_name"],
  body_variables: ["user_name"],
  button_variables: ["url_param"],
  buttons: [{ type: "quick_reply" }, { type: "url", variable: "url_param" }],
  active: true,
)

# Create whatsapp variables
WhatsappCredential.create(account: Account.first, business_id_meta: "1234", waba_id_meta: "829580149631389", app_id_meta: "123", app_secret: "4ac27f605e8333f79050446e9fc851f7", webhook_verify_token: "EAAU5YcWjogUBQRZBMuXclZAwCMeVr3l2nwcOxfvq1vH7Psbhhfy4b6p0ddmLZCzBpmWaPk1l8TZBvQ8UabkvtWZB7I1MMqFZAzSuwZBse4AcmHxIZAO2dyZCJYmFeN2GCNQwJJOYCXG7zbbBJAZBV2TGEZA3MIgqxciZARGySo7x2sUtovK5xwPxaSmmU25OK6onuIz4GFCNEMl3UUI7hjmfkDHA60lQ6GcPHx4zsnzQYK17Q3DYeSRUiyz91ZAP0oVWMzHV6ZBCvUYRJOcFfOh5tVkFnDm9DfaVnSQL6LlQZDZD", access_token: "EAAU5YcWjogUBQTSYBmh9pBn386ZANfJPwCeZCOWwZBhZA94y50R4nGs3pwSaJSaJqJWXmTbwtDqCYO4GWMJ12rbFyjOJsGjTD0lKOVqZC6FKf0LtfojpHl8Ab26UlFFADsvhyDziIeeIlo9YdQZBZCl0b3wlMQbQzpPt1oEJUORo361FTiM4W93ZCTXshBXgWwZDZD")

# API Payload Structure:

# 1: Doc template:
# -------------------

{
  "messages": [{
    "message_type": "template_message",
    "recipients": [
      { "name": "Pankaj", "mobile_no": "917488430065" },
    ],
    "sender_phone_number": "5551811580",
    "template_name": "document_template",
    "language_code": "en_US",

    "header_vars": {
      "date": "23 Feb",
    },

    "body_vars": {
      "amount": "500 Rs",
      "location": "Gopur Square",
      "doc_type": "Invoice",
    },

    "button_vars": {
      "tracking_code": "ZX9911",
    },

    "media_url": "https://7990e92da0d3.ngrok-free.app/dummy.pdf",
    "filename": "invoice.pdf",
  }],
}

# 2: Video template:
# ------------------

{
  "messages": [{
    "message_type": "template_message",
    "recipients": [
      { "name": "Pankaj", "mobile_no": "917488430065" },
    ],
    "sender_phone_number": "5551811580",
    "template_name": "vid_template",
    "language_code": "en_US",

    "header_vars": {
      "date": "23 Feb",
    },

    "body_vars": {
      "amount": "500 Rs",
      "location": "Gopur Square",
      "doc_type": "Invoice",
    },

    "button_vars": {
      "tracking_code": "ZX9911",
    },

    "media_url": "https://7990e92da0d3.ngrok-free.app/dummy.mp4",
    "filename": "invoice.pdf",
  }]
}

# 3: Non-Template Message:
# ------------------------

{
  "messages": [{
    "message_type": "non_template_message",
    "recipients": [
      { "name": "Pankaj", "mobile_no": "917488430065" },
    ],
    "body_text": "Hello from API.Test Message",
    "sender_phone_number": "5551811580",
    "template_name": "vid_template",
    "language_code": "en_US",

    "header_vars": {
      "date": "23 Feb",
    },

    "body_vars": {
      "amount": "500 Rs",
      "location": "Gopur Square",
      "doc_type": "Invoice",
    },

    "button_vars": {
      "tracking_code": "ZX9911",
    },

    "media_url": "https://7990e92da0d3.ngrok-free.app/dummy.mp4",
    "filename": "invoice.pdf",
  }]
}

# 4: Test Template:
# -------------------

{
  "messages": [{
    "message_type": "template_message",
    "recipients": [
      { "name": "Pankaj", "mobile_no": "917488430065" },
    ],
    "sender_phone_number": "5551811580",
    "template_name": "hello_world",
    "language_code": "en_US",

    "header_vars": {
      "date": "23 Feb",
    },

    "body_vars": {
      "name": "John",
      "order_id": "ORD77891",
    },

    "button_vars": {
      "tracking_code": "ZX9911",
    },

    "media_url": "https://example.com/invoice.pdf",
    "filename": "invoice.pdf",
  }]
}
