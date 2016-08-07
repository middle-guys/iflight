class CreatePassengers < ActiveRecord::Migration[5.0]
  def change
    create_table :passengers do |t|
      t.references :order, foreign_key: true
      t.integer :no
      t.datetime :dob
      t.string :category
      t.integer :depart_lug_weight
      t.integer :return_lug_weight

      t.timestamps
    end
  end
end
