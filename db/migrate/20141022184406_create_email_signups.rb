class CreateEmailSignups < ActiveRecord::Migration
  def change
    create_table :email_signups do |t|
      t.string :email

      t.timestamps
    end
    add_index :email_signups, :email
  end
end
