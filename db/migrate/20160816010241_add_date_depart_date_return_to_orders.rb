class AddDateDepartDateReturnToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :date_depart, :datetime
    add_column :orders, :date_return, :datetime
  end
end
