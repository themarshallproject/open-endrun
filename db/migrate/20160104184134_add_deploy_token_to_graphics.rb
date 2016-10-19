class AddDeployTokenToGraphics < ActiveRecord::Migration
  def change
    add_column :graphics, :deploy_token, :text
    add_index :graphics, :deploy_token
  end
end
