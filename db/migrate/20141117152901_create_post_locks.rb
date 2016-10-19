class CreatePostLocks < ActiveRecord::Migration
  def change
    create_table :post_locks do |t|
      t.integer :post_id
      t.integer :user_id
      t.datetime :acquired_at

      t.timestamps
    end
    add_index :post_locks, :post_id
    add_index :post_locks, :user_id
    add_index :post_locks, :acquired_at
  end
end
