class CreateAppointments < ActiveRecord::Migration[6.0]
  def change
    create_table :appointments do |t|
      t.integer :request_id
      t.string :reference_num
      t.string :name
      t.string :provider
      t.string :city
      t.string :state
      t.string :zip
      t.text :coach_notes
      t.string :communication_status
      t.datetime :date
      t.datetime :time
      t.timestamps
    end
  end
end
