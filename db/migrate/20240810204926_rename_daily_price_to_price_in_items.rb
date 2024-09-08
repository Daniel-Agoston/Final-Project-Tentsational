class RenameDailyPriceToPriceInItems < ActiveRecord::Migration[7.1]
  def change
    rename_column :items, :daily_price, :price
  end
end
