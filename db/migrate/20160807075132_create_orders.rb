class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :order_number
      t.references :user, foreign_key: true
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :contact_gender
      t.integer :adult
      t.integer :child
      t.integer :infant
      t.integer :ori_airport_id
      t.integer :des_airport_id
      t.string :status
      t.datetime :time_expired
      t.decimal :price_total

      t.timestamps
    end
  end
end
