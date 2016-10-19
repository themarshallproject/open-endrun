class AddCollectionSummaryToTags < ActiveRecord::Migration
  def change
    add_column :tags, :collection_summary, :text
  end
end
