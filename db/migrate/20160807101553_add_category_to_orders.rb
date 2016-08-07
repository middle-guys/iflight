class AddCategoryToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :category, :string
  end
end
