class AddDeckToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :deck, :text
  end
end
