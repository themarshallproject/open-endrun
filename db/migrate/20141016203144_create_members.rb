class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :email
      t.string :token
      t.datetime :last_seen_at
      t.string :last_ip
      t.boolean :active

      t.timestamps
    end
    add_index :members, :email
    add_index :members, :token
    add_index :members, :active
  end
end
