class AddTitleAndDescToStaticPages < ActiveRecord::Migration
  def change
    add_column :static_pages, :title, :text
    add_column :static_pages, :description, :text
  end
end
