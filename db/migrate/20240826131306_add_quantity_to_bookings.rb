class AddQuantityToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :quantity, :integer
  end
end
