class CreateFlights < ActiveRecord::Migration[5.0]
  def change
    create_table :flights do |t|
      t.references :order, foreign_key: true
      t.string :category
      t.references :plane_category, foreign_key: true
      t.datetime :time_depart
      t.datetime :time_arrive
      t.string :code_flight
      t.string :code_book
      t.decimal :price_web
      t.decimal :price_total

      t.timestamps
    end
  end
end
