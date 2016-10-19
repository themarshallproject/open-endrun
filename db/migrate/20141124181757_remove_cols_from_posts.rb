class RemoveColsFromPosts < ActiveRecord::Migration
  def change
  	remove_column :posts, :post_format_id
  	remove_column :posts, :serialized_draft
  end
end
