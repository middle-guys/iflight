class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :name, :string
    add_column :users, :phone, :string
    add_column :users, :gender, :string
    add_column :users, :is_admin, :boolean
    add_column :users, :is_registered, :boolean
  end
end
