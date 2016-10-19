class CreateUserPostAssignments < ActiveRecord::Migration
  def change
    create_table :user_post_assignments do |t|
      t.integer :user_id
      t.integer :post_id
      t.integer :position

      t.timestamps
    end
    add_index :user_post_assignments, :user_id
    add_index :user_post_assignments, :post_id
    add_index :user_post_assignments, :position
  end
end
