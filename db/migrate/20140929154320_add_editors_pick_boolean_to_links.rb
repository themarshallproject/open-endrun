class AddEditorsPickBooleanToLinks < ActiveRecord::Migration
  def change
    add_column :links, :editors_pick, :boolean
    add_index :links, :editors_pick
  end
end
