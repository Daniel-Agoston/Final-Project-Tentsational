class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :daily_price
      t.text :description

      t.timestamps
    end
  end
end
