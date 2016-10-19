class AddFbCountToLinks < ActiveRecord::Migration
  def change
    add_column :links, :facebook_count, :integer
  end
end
