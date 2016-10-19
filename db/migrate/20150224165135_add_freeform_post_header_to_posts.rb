class AddFreeformPostHeaderToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :freeform_post_header, :string
  end
end
