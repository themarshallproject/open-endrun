class ChangeFreeformPostHeaderToText < ActiveRecord::Migration
  def change
  	change_column :posts, :freeform_post_header, :text
  end
end
