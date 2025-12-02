class CustomerMessage < ApplicationRecord
  belongs_to :customer
  belongs_to :message
end
