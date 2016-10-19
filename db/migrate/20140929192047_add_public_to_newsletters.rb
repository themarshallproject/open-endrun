class AddPublicToNewsletters < ActiveRecord::Migration
  def change
    add_column :newsletters, :public, :boolean
    add_index :newsletters, :public
  end
end
