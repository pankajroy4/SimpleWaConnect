class Template < ApplicationRecord
  class MissingVariablesError < StandardError; end

  belongs_to :account
  validates :name, :language_code, :account, :media_type, presence: true

  def validate_variables_presence!(vars)
    required = Array(body_variables).map(&:to_s)

    missing = required.select do |key|
      val = vars[key]
      val.nil? || val.to_s.strip == ""
    end

    raise MissingVariablesError, "Missing or empty variables: #{missing.join(", ")}" if missing.any?

    true
  end
end
