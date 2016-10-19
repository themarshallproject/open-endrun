class AddTweetCountToLinks < ActiveRecord::Migration
  def change
    add_column :links, :tweet_count, :integer
  end
end
