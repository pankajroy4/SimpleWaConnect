class Messages::FindOrCreateCustomer
  def self.call(account:, recipient:, bulk_created:)
    phone = recipient[:mobile_no]
    name = recipient[:name]

    Customer.find_or_create_by!(account: account, phone_number: phone) do |c|
      c.name = name
      c.bulk_created = bulk_created
    end
  end
end
