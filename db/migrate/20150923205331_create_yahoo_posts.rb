class CreateYahooPosts < ActiveRecord::Migration
  def change
    create_table :yahoo_posts do |t|
      t.integer :post_id
      t.text :title
      t.boolean :published

      t.timestamps null: false
    end
    add_index :yahoo_posts, :post_id
    add_index :yahoo_posts, :published
  end
end
