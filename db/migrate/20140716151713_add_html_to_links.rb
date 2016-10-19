class AddHtmlToLinks < ActiveRecord::Migration
  def change
    add_column :links, :html, :text
  end
end
