class CreatePartnerPageviews < ActiveRecord::Migration
  def change
    create_table :partner_pageviews do |t|
      t.integer :post_id
      t.integer :partner_id
      t.text :url
      t.integer :pageviews

      t.timestamps null: false
    end
    add_index :partner_pageviews, :post_id
    add_index :partner_pageviews, :partner_id
  end
end
