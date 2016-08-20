class CreateSearchHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :search_histories do |t|
      t.references :route, foreign_key: true

      t.timestamps
    end
  end
end
