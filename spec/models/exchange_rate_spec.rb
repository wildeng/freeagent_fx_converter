require 'rails_helper'

describe ExchangeRate do
  # setting test data
  # euro is the default currency so its rate
  # is assumed to be 1 (no need to save it in DB)
  before(:each) do
    # currency that I have to convert
    cur_from = {
      id: 3,
      currency_slug: "USD",
      description: "US Dollars",
      default_currency: false
    }
    # goal currency
    cur_to = {
      id: 4,
      currency_slug: "GBP",
      description: "British Pounds",
      default_currency: false

    }
    # rate of the currency I have to convert related to euro
    rate_from ={
      rate: "1.0587",
      ecb_time: "2017-02-27"
    }

    # goal rate related to euro
    rate_to ={
      rate: "0.8528",
      ecb_time: "2017-02-27"
    }

    cur_default = {
      id: 5,
      currency_slug: "EUR",
      description: "Euro"
    }
    @curfrom = FactoryGirl.create(:currency_converter, cur_from)
    @curto = FactoryGirl.create(:currency_converter, cur_to)
    @ratefrom = FactoryGirl.create(:exchange_rate, rate_from)
    @ratefrom.currency_converter = @curfrom
    @ratefrom.save
    @rateto = FactoryGirl.create(:exchange_rate, rate_to)
    @rateto.currency_converter = @curto
    @rateto.save
    @eur = FactoryGirl.create(:currency_converter)
  end


  describe "get rate" do
    it "should have an at method" do
      expect(ExchangeRate.respond_to?(:at)).to eq(true)
    end

    it "should have a get_default_rate method" do
      expect(ExchangeRate.respond_to?(:get_default_rate)).to eq(true)
    end

    it "should find the right rate" do
      rate = ExchangeRate.at("2017-02-27", @curfrom.id, @curto.id)
      expect(rate.round(7)).to eq(0.8055162)
    end

    it "should give the right conversion" do
      result = 100 * ExchangeRate.at("2017-02-27", @curfrom.id, @curto.id)
      expect(result.round(5)).to eq(80.55162)
    end

    it "should return nil as rate" do
      rate = ExchangeRate.at("2017-02-27", @curfrom.id, @eur.id)
      expect(rate.round(5)).to eq(0.94455)
    end

    it "should return one as rate between same currency" do
      rate = ExchangeRate.at("2017-02-27", @curto.id, @curto.id)
      expect(rate).to eq(1)
    end

    # using fake data to raise an active record not found
    # and catch it with begin rescue
    it "should not raise an error" do
      rate = ExchangeRate.at("2017-02-27", 10, 20)
      expect(rate).to eq(nil)
    end
  end

  describe "insert rate" do
    it "should have a save_data method" do
      expect(ExchangeRate.respond_to?(:save_data)).to eq(true)
    end

    it "should have a read_ecb_data method" do
      expect(ExchangeRate.respond_to?(:read_ecb_data)).to eq(true)
    end

    it "should save a new rate" do
      cur_slug = "NZD"
      cur_rate = "1.5105"
      cur_time = "2016-12-05"
      ExchangeRate.save_data(cur_time, cur_slug, cur_rate)

      expect(CurrencyConverter.find_by_currency_slug(cur_slug).currency_slug).to eq(cur_slug)
      expect(ExchangeRate.find_by_ecb_time(cur_time).rate).to eq(cur_rate.to_f)
    end

    it "should add a new rate to an existing slug" do
      cur_slug = "USD"
      cur_rate = "1.5105"
      cur_time = "2016-12-05"
      old_rate = "1.0587"
      old_time = "2017-02-27"
      currency = CurrencyConverter.find_by_currency_slug(cur_slug)
      # inserting new rate
      ExchangeRate.save_data(cur_time, cur_slug, cur_rate)
      # checking new data
      expect(currency.exchange_rates.find_by_ecb_time(cur_time).rate).to eq(cur_rate.to_f)
      # checking old data
      expect(currency.exchange_rates.find_by_ecb_time(old_time).rate).to eq(old_rate.to_f)
    end
  end
end
