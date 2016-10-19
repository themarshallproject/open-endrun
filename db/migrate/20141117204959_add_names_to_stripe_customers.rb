class AddNamesToStripeCustomers < ActiveRecord::Migration
  def change
    add_column :stripe_customers, :first_name, :string
    add_column :stripe_customers, :last_name, :string
  end
end
