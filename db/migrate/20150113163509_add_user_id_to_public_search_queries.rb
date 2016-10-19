class AddUserIdToPublicSearchQueries < ActiveRecord::Migration
  def change
    add_column :public_search_queries, :user_id, :integer
  end
end
