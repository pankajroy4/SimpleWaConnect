# Create Account and Whatsapp Phone Number record
Account.create!(
  name: "Demo Account",
  platform: "simpledairy",
  whatsapp_phone_numbers_attributes: [ # Nested attributes for phone numbers
    {
      phone_number_id: "809219032271174",
      display_number: "5551811580",  # Whatsapp account mobile display number - without country code
      status: :active,
      country_code: "1",
    },
  ],
)

WhatsappPhoneNumber.create(account: Account.first, phone_number_id: "809219032271174", display_number: "5551811580", status: 0, country_code: "1")

User.create!(
  email: "test@gmail.com",
  password: "111111",
  password_confirmation: "111111",
  account: Account.last,
  role: "admin",
)

# Create Templates record
Template.create!(
  account: Account.last,
  name: "hello_world",
  language_code: "en_US",
  has_header: false,
  media_type: "text",       # no media needed
  header_variables: [],
  body_variables: [],
  button_variables: [],
  header_var_count: 0,
  body_var_count: 0,
  button_var_count: 0,
  active: true,
)

Template.create!(
  account: Account.last,
  name: "vid_template",
  language_code: "en_US",
  has_header: true,
  media_type: "video",
  header_variables: [],
  body_variables: [],
  button_variables: [],
  header_var_count: 0,
  body_var_count: 0,
  button_var_count: 0,
  active: true,
)

Template.create!(
  account: Account.last,
  name: "document_template",
  language_code: "en_US",
  has_header: true,
  media_type: "document",
  header_variables: [],
  body_variables: ["amount", "location", "doc_type"],
  button_variables: [],
  header_var_count: 0,
  body_var_count: 3,
  button_var_count: 0,
  active: true,
)

# Create whatsapp variables
WhatsappCredential.create(account: Account.first, business_id: "1234", waba_id: "829580149631389", app_id: "123", app_secret: "4ac27f605e8333f79050446e9fc851f7", webhook_verify_token: "EAAU5YcWjogUBP6jnEdiFo9B50YPJTneNSx4qvSFkmD64vyVVnZAO8HeTb7s10rCT8bZAcQeDrNgYeiPxuAbTBAlsARO8ZCa5d3qKKLTYV9xPjnpiZACGI7ChDRxYpJZB1cHrHL5lI26Ms00lEuCeAfY31EmQznOUpP7xMycPC7xoO7Huha2yGee8rPOhfpJdTnyYTmjdpqQEOBDr6agnsCc5eHq7ZCSHZAAXW2VBG8HqShkJDTME8elOBJ1j1mopDGMP2lQF09rliLZCmRp0ZCZBD2MpcJk9jJDZBapQuOZCJOsZD", access_token: "EAAU5YcWjogUBP1rfyFRjBcZBx0EJZBZBe8ZCyuyPZCcLRDYFENYwNgiH7ifszPTjIwbzfMgcZBZBhiMakiMB2YfczlDELsXa5jLycZAZCOyVgfmZB0Rk9fB3VVWahI3ZAoC99UOqRGNnkujzSux8QziSYDObbMnEFnKJkxhXctZBdcutyojLpAX7F5nYNFjScsv9h5D3xFZAFjrNAWMVMVlFHrcxZCJ2KSEfRYswIUrkRVRWfa")

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
