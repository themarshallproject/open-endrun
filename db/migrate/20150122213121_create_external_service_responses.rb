class CreateExternalServiceResponses < ActiveRecord::Migration
  def change
    create_table :external_service_responses do |t|
      t.string :action
      t.text :response

      t.timestamps null: false
    end
    add_index :external_service_responses, :action
  end
end
