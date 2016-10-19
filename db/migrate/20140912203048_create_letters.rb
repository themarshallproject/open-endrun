class CreateLetters < ActiveRecord::Migration
  def change
    create_table :letters do |t|
      t.string :name
      t.string :email
      t.string :twitter
      t.text :street_address
      t.boolean :is_anonymous
      t.text :content
      t.integer :post_id
      t.string :status
      t.boolean :stream_promo
      t.text :excerpt

      t.timestamps
    end
    add_index :letters, :post_id
    add_index :letters, :status
  end
end
