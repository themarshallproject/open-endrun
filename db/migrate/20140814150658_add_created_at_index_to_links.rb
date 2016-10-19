class AddCreatedAtIndexToLinks < ActiveRecord::Migration
  def change
  	add_index :links, :created_at
  end
end
