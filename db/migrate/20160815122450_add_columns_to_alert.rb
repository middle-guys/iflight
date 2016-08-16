class AddColumnsToAlert < ActiveRecord::Migration[5.0]
  def change
    add_column :alerts, :status, :string
    add_column :alerts, :token, :string
  end
end
