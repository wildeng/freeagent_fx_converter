class CreateCurrencyConverters < ActiveRecord::Migration
  def change
    create_table :currency_converters do |t|
      t.string :currency_slug, limit: 3
      t.string :description
      t.boolean :default_currency, default: false
      t.timestamps null: false
    end
    add_index :currency_converters, :currency_slug, unique: true
  end
end
