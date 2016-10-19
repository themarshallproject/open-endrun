class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.string :resource_type
      t.integer :resource_id
      t.integer :rating
      t.integer :user_id

      t.timestamps
    end
    add_index :ratings, :resource_type
    add_index :ratings, :resource_id
    add_index :ratings, :user_id
  end
end
