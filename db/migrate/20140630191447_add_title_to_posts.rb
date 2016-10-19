class AddTitleToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :title, :text
    add_index :posts, :title
  end
end
