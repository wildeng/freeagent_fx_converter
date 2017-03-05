# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# create default currency
CurrencyConverter.create(id: 1, currency_slug: "EUR", description: "Euro", default_currency: true)

# reading ecb_data to seed db

ExchangeRate.read_ecb_data
