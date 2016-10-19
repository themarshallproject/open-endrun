class CreatePostVersions < ActiveRecord::Migration
  def change
    create_table :post_versions do |t|
      t.integer :post_id
      t.boolean :autosave
      t.text :content
      t.integer :user_id

      t.timestamps
    end
    add_index :post_versions, :post_id
    add_index :post_versions, :autosave
    add_index :post_versions, :user_id
  end
end
