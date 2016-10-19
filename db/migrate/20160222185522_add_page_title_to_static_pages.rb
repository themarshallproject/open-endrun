class AddPageTitleToStaticPages < ActiveRecord::Migration
  def change
    add_column :static_pages, :page_title, :text
  end
end
