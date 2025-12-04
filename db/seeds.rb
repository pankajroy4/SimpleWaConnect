
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


User.create!(
  email: "test@gmail.com",
  name: "Mohan",
  password: "111111",
  password_confirmation: "111111",
  account: Account.last,
  role: "admin",
)

Template.create!(
  account: Account.last,
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
  account: Account.last,
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
  account: Account.last,
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
  account: Account.last,
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
  account: Account.last,
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
WhatsappCredential.create(account: Account.first, business_id: "1234", waba_id: "829580149631389", app_id: "123", app_secret: "4ac27f605e8333f79050446e9fc851f7", webhook_verify_token: "EAAU5YcWjogUBP6jnEdiFo9B50YPJTneNSx4qvSFkmD64vyVVnZAO8HeTb7s10rCT8bZAcQeDrNgYeiPxuAbTBAlsARO8ZCa5d3qKKLTYV9xPjnpiZACGI7ChDRxYpJZB1cHrHL5lI26Ms00lEuCeAfY31EmQznOUpP7xMycPC7xoO7Huha2yGee8rPOhfpJdTnyYTmjdpqQEOBDr6agnsCc5eHq7ZCSHZAAXW2VBG8HqShkJDTME8elOBJ1j1mopDGMP2lQF09rliLZCmRp0ZCZBD2MpcJk9jJDZBapQuOZCJOsZD", access_token: "EAAU5YcWjogUBP1rfyFRjBcZBx0EJZBZBe8ZCyuyPZCcLRDYFENYwNgiH7ifszPTjIwbzfMgcZBZBhiMakiMB2YfczlDELsXa5jLycZAZCOyVgfmZB0Rk9fB3VVWahI3ZAoC99UOqRGNnkujzSux8QziSYDObbMnEFnKJkxhXctZBdcutyojLpAX7F5nYNFjScsv9h5D3xFZAFjrNAWMVMVlFHrcxZCJ2KSEfRYswIUrkRVRWfa")
