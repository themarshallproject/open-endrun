class AddProducedByToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :produced_by, :text
  end
end
