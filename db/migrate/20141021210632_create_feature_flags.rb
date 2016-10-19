class CreateFeatureFlags < ActiveRecord::Migration
  def change
    create_table :feature_flags do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
    add_index :feature_flags, :key
    add_index :feature_flags, :value
  end
end
