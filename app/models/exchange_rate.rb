# @author Alain Mauri
# this class calculates the exchange rate
# related bewteen two currencies
# default currency rate is assumed to be 1
# in database all other rates are saved
# all methods are static ones
# no need to instantiate the class

require 'nokogiri'
require 'open-uri'

class ExchangeRate < ActiveRecord::Base
  belongs_to :currency_converter

  # defining a scope to take only last 90 days rates 
  # older rates are not deleted
  ExchangeRate.scope :filter_by_date, -> (date) {where(" DATE(ecb_time) <= ? and DATE(ecb_time)>=?", date, date - 90.days)}

  # ecb url as a constant

  ECB_URL = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"

  # this is the method that does the actual conversion
  # it finds the selected currencies and their rates and then performs
  # the conversion rate following the formula rate_to/rate_from
  # @param rate_date date that to which rates are referred
  # @param from_id id of the currency that needs to be converted
  # @param to_id   id of the goal currency
  # @return conversion ratio (big decimal) or nil
  def self.at(rate_date, from_id, to_id)
    # using begin rescue so that we could return nil if something occurs
    begin
      # find the needed currencies
      cur_from = CurrencyConverter.find(from_id)
      cur_to = CurrencyConverter.find(to_id)

      # if currencies both exist find the related rates
      # and do the conversion
      if cur_from and cur_to
        if cur_from.default_currency
          rate_from = self.get_default_rate
        else
          rate_from = cur_from.exchange_rates.find_by_ecb_time(rate_date).rate
        end
        if cur_to.default_currency
          rate_to = self.get_default_rate
        else
          rate_to = cur_to.exchange_rates.find_by_ecb_time(rate_date).rate
        end
        # if both rates exist we can do the real calculation
        if rate_from and rate_to
          return rate_to/rate_from
        end
      end
      # to rescue from an error we could write in a log, a message
      # give some feedback or other
    rescue => e
      # logging the error message and the stacktrace
      logger.error e.message
      logger.error e.backtrace.join("\n")
      return nil
    end
    # in any other case return nil
    return nil
  end

  # returns the default rate which is 1 by definition
  def self.get_default_rate
    return 1
  end

  # method that parses ECB data only
  # ecb rates url is set as a constant
  # the method uses xpath to find all the nodes that have the time attribute
  # following ecb rates xml structure
  # it then parses all children to save data
  def self.read_ecb_data
    ecb_xml = Nokogiri::XML(open(ECB_URL))
    # selecting all nodes with time attribute
    ecb_xml.xpath("//*[@time]").each do |node|
      cur_time = node['time']
      # parsing each children and save data
      node.children.each do |rate|
        cur_slug = rate['currency']
        cur_rate = rate['rate']
        self.save_data(cur_time, cur_slug, cur_rate)
      end
    end
  end

  # this method saves data in database
  # if a currency is already in database
  # and the rate is not there it saves only the rate
  # otherwise it saves currency and rate
  # @param cur_time date of the rate
  # @param cur_slug current currency
  # @param cur_rate ecb rate of the currency
  def self.save_data(cur_time, cur_slug, cur_rate)
    begin
      # finding out if a currency is already in database
      currency = CurrencyConverter.find_by_currency_slug(cur_slug)

      # if it doesn't exist create a new one and save it
      if !currency
        currency = CurrencyConverter.new(currency_slug: cur_slug)
        currency.save
      end

      # find if a rate for the currency selected slug is there
      # if note create a new one
      # if it exists let's assume that it is not changed
      rate = currency.exchange_rates.find_by_ecb_time(Date.parse(cur_time))
      if !rate
        rate = ExchangeRate.new(ecb_time: cur_time, rate: cur_rate.to_f, currency_converter_id: currency.id)
        rate.save
      end
    rescue => e
      # logging the error message and the stacktrace
      logger.error e.message
      logger.error e.backtrace.join("\n")
    end
  end
end
