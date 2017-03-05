class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table :exchange_rates do |t|
      t.decimal :rate, precision: 16, scale: 5
      t.date    :ecb_time
      t.integer :currency_converter_id, limit: 11
      t.timestamps null: false
    end
    add_index :exchange_rates, [ :ecb_time,  :currency_converter_id ], unique: true
  end
end
