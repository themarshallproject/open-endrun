class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.text :label
      t.text :config

      t.timestamps null: false
    end
  end
end
