class CurrencyConvertersController < ApplicationController
  before_action :set_currency_converter, only: [:show, :edit, :update, :destroy]

  # GET /currency_converters
  # GET /currency_converters.json
  def index
    @currency_converters = CurrencyConverter.all
    @rates_dates = ExchangeRate.all.filter_by_date(Date.today)
  end


  # This one calls ExchangeRate.at and calculate the conversion
  def calculate_conversion
    converted_amount = nil

    # checking parameters before calculating the conversion rate
    if currency_converter_params[:rate_date] != "" or currency_converter_params[:from_cur] != "" or currency_converter_params[:to_cur] != ""
      rate = ExchangeRate.at( currency_converter_params[:rate_date].to_date, currency_converter_params[:from_cur], currency_converter_params[:to_cur])
      converted = false
      # rate is not nil go on and do the conversion
      if rate
        converted_amount = currency_converter_params[:amount].to_f * rate
        # rounding the amount to 5 decimal places
        converted_amount = converted_amount.round(5)
        converted = true

        # write the success message
        message = I18n.t('success_message', amount: converted_amount.to_s).html_safe
      else
        # failure message
        message = I18n.t('failure').html_safe
      end
    else
      # missing data message
      converted = false
      message = I18n.t('missed_data').html_safe
    end
    respond_to do |format|
      if converted
        format.json {render json: {success: true, message: message, amount: converted_amount} }
      else
        format.json {render json: {success: false, message: message, amount: ""}, status: 422 }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def currency_converter_params
      params.permit(:rate_date, :amount, :from_cur, :to_cur)
    end
end
