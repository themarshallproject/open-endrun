class AddHtmlUrlToLinks < ActiveRecord::Migration
  def change
    add_column :links, :html_url, :string
  end
end
