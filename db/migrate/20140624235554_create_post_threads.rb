class CreatePostThreads < ActiveRecord::Migration
  def change
    create_table :post_threads do |t|
      t.string :name

      t.timestamps
    end
    add_index :post_threads, :name
  end
end
