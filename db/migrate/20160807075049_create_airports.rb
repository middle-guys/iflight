class CreateAirports < ActiveRecord::Migration[5.0]
  def change
    create_table :airports do |t|
      t.string :code
      t.string :name
      t.string :name_unsigned
      t.string :short_name
      t.boolean :is_domestic

      t.timestamps
    end
  end
end
