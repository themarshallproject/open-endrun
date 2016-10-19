class CreatePostDelegatePaths < ActiveRecord::Migration
  def change
    create_table :post_delegate_paths do |t|
      t.integer :post_id
      t.boolean :active
      t.text :path

      t.timestamps null: false
    end
    add_index :post_delegate_paths, :post_id
    add_index :post_delegate_paths, :active
  end
end
