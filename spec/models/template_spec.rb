RSpec.describe Template, type: :model do
  it { should belong_to(:account) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:language_code) }
  it { should validate_presence_of(:media_type) }

  it "raises error when required vars missing" do
    template = build(:template, body_variables: ["name"])

    expect {
      template.validate_variables_presence!({})
    }.to raise_error(Template::MissingVariablesError)
  end

  it "passes when all variables present" do
    template = build(:template, body_variables: ["name"])

    expect(
      template.validate_variables_presence!({ "name" => "John" })
    ).to be true
  end
end
