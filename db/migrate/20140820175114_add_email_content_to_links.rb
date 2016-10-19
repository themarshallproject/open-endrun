class AddEmailContentToLinks < ActiveRecord::Migration
  def change
    add_column :links, :email_content, :text
  end
end
