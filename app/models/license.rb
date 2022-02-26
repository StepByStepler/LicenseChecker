class License < ApplicationRecord
  validates_presence_of :paid_till
end
