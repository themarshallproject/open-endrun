class CreatePostSharables < ActiveRecord::Migration
  def change
    create_table :post_sharables do |t|
      t.integer :post_id
      t.string :slug
      t.integer :photo_id
      t.text :facebook_headline
      t.text :facebook_description
      t.text :twitter_headline

      t.timestamps null: false
    end
    add_index :post_sharables, :post_id
    add_index :post_sharables, :slug
  end
end
