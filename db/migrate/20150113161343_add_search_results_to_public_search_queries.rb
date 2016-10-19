class AddSearchResultsToPublicSearchQueries < ActiveRecord::Migration
  def change
    add_column :public_search_queries, :search_results, :text
  end
end
