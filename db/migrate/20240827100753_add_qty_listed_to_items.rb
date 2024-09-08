class AddQtyListedToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :qty_listed, :integer
  end
end
