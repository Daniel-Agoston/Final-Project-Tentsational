class AddDefaultToQuantityInItems < ActiveRecord::Migration[7.1]
  def change
    change_column_default :items, :quantity, 0
  end
end
