class AddSummaryToYahooPosts < ActiveRecord::Migration
  def change
    add_column :yahoo_posts, :summary, :text
  end
end
