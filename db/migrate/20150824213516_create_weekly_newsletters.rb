class CreateWeeklyNewsletters < ActiveRecord::Migration
  def change
    create_table :weekly_newsletters do |t|
      t.string :name
      t.text :email_subject
      t.string :mailchimp_id
      t.string :mailchimp_web_id
      t.text :byline
      t.datetime :published_at
      t.boolean :public
      t.text :archive_url
      t.text :opening_graf
      t.text :quote_graf

      t.timestamps null: false
    end
    add_index :weekly_newsletters, :mailchimp_id
    add_index :weekly_newsletters, :mailchimp_web_id
    add_index :weekly_newsletters, :published_at
    add_index :weekly_newsletters, :public
  end
end
