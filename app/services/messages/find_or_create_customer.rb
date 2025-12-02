class Messages::FindOrCreateCustomer
  def self.call(account:, message:, recipients:)
    phone_numbers = recipients.map { |r| r[:mobile_no] }

    # Load existing customers once
    existing = Customer.where(account: account, phone_number: phone_numbers).index_by(&:phone_number)

    # Build missing customers
    new_records = recipients.filter_map do |r|
      next if existing[r[:mobile_no]]
      Customer.new(account: account, phone_number: r[:mobile_no], name: r[:name])
    end

    # Bulk insert new customers
    if new_records.any?
      import_result = Customer.import(new_records, validate: true)

      if import_result.failed_instances.any?
        errors = import_result.failed_instances.flat_map(&:errors).map(&:full_message)
        raise ActiveRecord::Rollback, errors
      end

      # Reload customers including newly created ones
      existing = Customer.where(account: account, phone_number: phone_numbers).index_by(&:phone_number)
    end

    # Build join rows
    join_records = recipients.map do |r|
      CustomerMessage.new(customer: existing[r[:mobile_no]], message: message)
    end

    # Bulk insert joins
    join_result = CustomerMessage.import(join_records, validate: true)

    if join_result.failed_instances.any?
      errors = join_result.failed_instances.flat_map(&:errors).map(&:full_message)
      raise ActiveRecord::Rollback, errors
    end

    true
  end
end
