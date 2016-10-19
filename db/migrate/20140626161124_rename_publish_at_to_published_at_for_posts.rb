class RenamePublishAtToPublishedAtForPosts < ActiveRecord::Migration
  def change
  	rename_column :posts, :publish_at, :published_at
  end
end
