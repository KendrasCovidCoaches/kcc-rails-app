class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.integer :user_id
      t.string :name, null: false, default: ""
      t.string :description, null: false, default: ""
      t.string :participants, null: false, default: ""
      t.string :looking_for, null: false, default: ""
      t.string :patient_location, default: "", null: false
      t.string :contact, default: "", null: false
      t.boolean :highlight, default: false, null: false
      t.string :progress, default: "", null: false
      t.string :docs_and_demo, default: "", null: false
      t.string :number_of_patients, default: "", null: false
      t.string :links, default: ""
      t.string :status, default: "", null: false
      t.boolean :accepting_patients, default: true
      t.string :short_description, default: "", null: false
      t.string :target_country, default: "", null: false
      t.string :target_location, default: "", null: false
      t.string :organization_status, default: "", null: false
      t.string :ein
      t.string :organization, default: ""
      t.string :level_of_urgency, default: "", null: false
      t.string :start_date, default: ""
      t.string :end_date, default: ""
      t.string :compensation, default: ""
      t.string :organization_mission
      t.boolean :organization_registered
      t.boolean :end_date_recurring
      t.string :level_of_exposure
      t.boolean :background_screening_required
      t.timestamps
    end
  end
end
