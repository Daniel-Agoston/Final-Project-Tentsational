class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
