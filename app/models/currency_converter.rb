class CurrencyConverter < ActiveRecord::Base
  has_many :exchange_rates
end
