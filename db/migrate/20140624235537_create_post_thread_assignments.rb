class CreatePostThreadAssignments < ActiveRecord::Migration
  def change
    create_table :post_thread_assignments do |t|
      t.integer :post_id
      t.integer :post_thread_id

      t.timestamps
    end
    add_index :post_thread_assignments, :post_id
    add_index :post_thread_assignments, :post_thread_id
  end
end
