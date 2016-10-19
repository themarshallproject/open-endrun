class AddRemoteAliveToLinks < ActiveRecord::Migration
  def change
    add_column :links, :remote_is_alive, :boolean
    add_index :links, :remote_is_alive
  end
end
