class CreateNewsletterAssignments < ActiveRecord::Migration
  def change
    create_table :newsletter_assignments do |t|
      t.string :taggable_type
      t.integer :taggable_id
      t.integer :newsletter_id
      t.integer :position
      t.string :bucket

      t.timestamps
    end
    add_index :newsletter_assignments, :taggable_type
    add_index :newsletter_assignments, :taggable_id
    add_index :newsletter_assignments, :newsletter_id
    add_index :newsletter_assignments, :bucket
  end
end
