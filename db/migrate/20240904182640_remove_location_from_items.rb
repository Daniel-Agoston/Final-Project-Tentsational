class RemoveLocationFromItems < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:items, :location)
      remove_column :items, :location, :geography
    end
  end
end
