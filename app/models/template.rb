class Template < ApplicationRecord
  class MissingVariablesError < StandardError; end

  belongs_to :account

  validates :name, :language_code, presence: true

  def validate_variables_presence!(vars)
    required = Array(variables).map(&:to_s)

    missing = required.select do |key|
      val = vars[key]
      val.nil? || val.to_s.strip == ""
    end

    if missing.any?
      raise MissingVariablesError, "Missing or empty variables: #{missing.join(", ")}"
    end

    true
  end
end
