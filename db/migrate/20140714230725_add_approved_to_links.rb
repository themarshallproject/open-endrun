class AddApprovedToLinks < ActiveRecord::Migration
  def change
    add_column :links, :approved, :boolean
    add_index :links, :approved
  end
end
