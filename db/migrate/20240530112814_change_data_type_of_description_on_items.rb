class ChangeDataTypeOfDescriptionOnItems < ActiveRecord::Migration[7.1]
  def change
    change_column :items, :description, :string
  end
end
