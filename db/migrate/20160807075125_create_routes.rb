class CreateRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :routes do |t|
      t.integer :ori_airport_id
      t.integer :des_airport_id
      t.boolean :is_domestic

      t.timestamps
    end
  end
end
