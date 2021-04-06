class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.integer :user_id
      t.string :patient_email, null: false, default: ""
      t.string :f_name, null: false, default: ""
      t.string :l_name, null: false, default: ""
      t.datetime :birth_date, null: false, default: ""
      t.string :phone, default: "", null: false
      t.string :address, default: "", null: false
      t.boolean :highlight, default: false, null: false
      t.string :city, default: "", null: false
      t.string :state, default: "", null: false
      t.string :zip, default: "", null: false
      t.string :sex, default: "", null: false
      t.string :pref_language, default: "", null: false
      t.boolean :self_book, default: true, null: false
      t.string :closest_city, default: "", null: false
      t.string :travel_radius, default: "", null: false
      t.string :weekday_avail, default: "", null: false
      t.string :weekday_times, default: "", null: false
      t.string :weekend_avail, default: "", null: false
      t.string :weekend_times, default: "", null: false
      t.string :eligibility_group, default: "", null: false
      t.boolean :critical_to_book_with, default: false
      t.string :book_with_full_name, default: ""
      t.string :book_with_email, default: ""
      t.string :book_with_phone
      t.boolean :open_to_same_day
      t.text :notes
      t.string :requested_by_email, default: ""
      t.string :requested_by_name, default: ""
      t.boolean :over_50
      t.timestamps
    end
  end
end
