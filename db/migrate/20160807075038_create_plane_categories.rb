class CreatePlaneCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :plane_categories do |t|
      t.string :category
      t.string :name
      t.string :short_name

      t.timestamps
    end
  end
end
