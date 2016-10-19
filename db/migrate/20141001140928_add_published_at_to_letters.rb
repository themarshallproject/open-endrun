class AddPublishedAtToLetters < ActiveRecord::Migration
  def change
    add_column :letters, :published_at, :datetime
    add_index :letters, :published_at
  end
end
