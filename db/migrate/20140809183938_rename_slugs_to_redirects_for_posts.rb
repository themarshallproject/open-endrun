class RenameSlugsToRedirectsForPosts < ActiveRecord::Migration
  def change
  	rename_column :posts, :slugs, :redirects
  end
end
