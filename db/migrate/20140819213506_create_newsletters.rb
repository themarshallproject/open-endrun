class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :name
      t.string :email_subject
      t.integer :mailchimp_id
      t.text :blurb
      t.text :template

      t.timestamps
    end
  end
end
