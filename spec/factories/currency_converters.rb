FactoryGirl.define do
  factory :currency_converter do |f|
    f.id 1
    f.currency_slug "EUR"
    f.description "Euro"
    f.default_currency true
  end
end
