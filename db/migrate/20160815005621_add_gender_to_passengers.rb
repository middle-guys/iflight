class AddGenderToPassengers < ActiveRecord::Migration[5.0]
  def change
    add_column :passengers, :gender, :string
  end
end
