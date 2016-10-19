class CreatePublicSearchQueries < ActiveRecord::Migration
  def change
    create_table :public_search_queries do |t|
      t.text :query
      t.string :token
      t.text :referer

      t.timestamps
    end
    add_index :public_search_queries, :query
    add_index :public_search_queries, :token
  end
end
