class AddDisplayHeadlineToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :display_headline, :text
  end
end
