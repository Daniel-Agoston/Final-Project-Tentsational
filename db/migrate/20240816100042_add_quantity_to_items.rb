class AddQuantityToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :quantity, :integer
  end
end
