class AddHomepagePositionToNewsletterAssignments < ActiveRecord::Migration
  def change
    add_column :newsletter_assignments, :homepage_position, :integer
    add_index  :newsletter_assignments, :homepage_position
  end
end
