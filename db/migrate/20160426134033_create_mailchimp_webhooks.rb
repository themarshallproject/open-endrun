class CreateMailchimpWebhooks < ActiveRecord::Migration
  def change
    create_table :mailchimp_webhooks do |t|
      t.string :event_type
      t.string :email
      t.text :payload

      t.timestamps null: false
    end
    add_index :mailchimp_webhooks, :event_type
    add_index :mailchimp_webhooks, :email
  end
end
