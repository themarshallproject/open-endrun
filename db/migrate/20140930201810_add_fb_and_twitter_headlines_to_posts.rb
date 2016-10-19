class AddFbAndTwitterHeadlinesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :facebook_headline, :text
    add_column :posts, :twitter_headline, :text
  end
end
