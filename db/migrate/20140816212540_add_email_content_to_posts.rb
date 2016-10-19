class AddEmailContentToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :email_content, :text
  end
end
