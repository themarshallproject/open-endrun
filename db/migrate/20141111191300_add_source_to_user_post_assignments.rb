class AddSourceToUserPostAssignments < ActiveRecord::Migration
  def change
    add_column :user_post_assignments, :source, :string
    add_index :user_post_assignments, :source
  end
end
