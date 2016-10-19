class CreateStripeCustomers < ActiveRecord::Migration
  def change
    create_table :stripe_customers do |t|
      t.string :stripe_customer_id
      t.string :email
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :amount
      t.string :custom_amount
      t.string :plan
      t.string :donation_type
      t.string :phone
      t.string :inbound_source

      t.timestamps
    end
    add_index :stripe_customers, :stripe_customer_id
    add_index :stripe_customers, :email
  end
end
