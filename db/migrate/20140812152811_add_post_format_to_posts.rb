class AddPostFormatToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :post_format, :string
    add_index :posts, :post_format
  end
end
