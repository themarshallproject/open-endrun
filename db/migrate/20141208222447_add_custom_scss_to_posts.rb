class AddCustomScssToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :custom_scss, :text
  end
end
