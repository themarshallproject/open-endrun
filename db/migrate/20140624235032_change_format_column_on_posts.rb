class ChangeFormatColumnOnPosts < ActiveRecord::Migration
  def change
  	rename_column :posts, :format_id, :post_format_id
  end
end
