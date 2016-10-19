class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.integer :user_id
      t.integer :events

      t.timestamps
    end
    add_index :user_sessions, :user_id
  end
end
