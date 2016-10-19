class CreateLinkReports < ActiveRecord::Migration
  def change
    create_table :link_reports do |t|
      t.integer :link_id
      t.integer :tag_id
      t.integer :user_id
      t.text :url
      t.string :status

      t.timestamps null: false
    end
    add_index :link_reports, :link_id
    add_index :link_reports, :tag_id
    add_index :link_reports, :user_id
    add_index :link_reports, :status
  end
end
