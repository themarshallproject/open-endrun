class AddSidebarToTags < ActiveRecord::Migration
  def change
    add_column :tags, :sidebar_description, :text
  end
end
