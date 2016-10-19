class AddCustomHeadToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :inject_html, :text
  end
end
