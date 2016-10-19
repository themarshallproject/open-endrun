class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :twitter
      t.text :bio

      t.timestamps
    end
    add_index :users, :email
    add_index :users, :twitter
  end
end
