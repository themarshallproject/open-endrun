class AddInStreamToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :in_stream, :boolean
    add_index :posts, :in_stream
  end
end
