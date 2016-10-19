class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :content
      t.integer :format_id
      t.datetime :publish_at
      t.string :status

      t.timestamps
    end
    add_index :posts, :format_id
    add_index :posts, :publish_at
    add_index :posts, :status
  end
end
