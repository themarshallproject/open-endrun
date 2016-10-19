class CreateWeeklyNewsletterAssignments < ActiveRecord::Migration
  def change
    create_table :weekly_newsletter_assignments do |t|
      t.string :taggable_type
      t.integer :taggable_id
      t.integer :weekly_newsletter_id
      t.integer :position
      t.string :bucket

      t.timestamps null: false
    end
    add_index :weekly_newsletter_assignments, :taggable_type
    add_index :weekly_newsletter_assignments, :taggable_id
    add_index :weekly_newsletter_assignments, :weekly_newsletter_id
    add_index :weekly_newsletter_assignments, :position
    add_index :weekly_newsletter_assignments, :bucket
  end
end
