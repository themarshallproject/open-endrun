class AddPublicFlagToTags < ActiveRecord::Migration
  def change
    add_column :tags, :public, :boolean
    add_index :tags, :public
  end
end
