class AddDeployApiKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deploy_api_key, :string
    add_index :users, :deploy_api_key
  end
end
