class AddUserIdToTaggings < ActiveRecord::Migration
  def change
    add_column :taggings, :user_id, :integer
    add_index :taggings, :user_id
  end
end
