class AddRevisedAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :revised_at, :datetime
    add_index :posts, :revised_at
  end
end
