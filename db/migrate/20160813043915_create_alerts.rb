class CreateAlerts < ActiveRecord::Migration[5.0]
  def change
    create_table :alerts do |t|
      t.string :email
      t.string :name
      t.integer :ori_air_id
      t.integer :des_air_id
      t.datetime :time_start
      t.decimal :price_expect

      t.timestamps
    end
  end
end
