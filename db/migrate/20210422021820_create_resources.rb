class CreateResources < ActiveRecord::Migration[6.0]
  def change
    create_table :resources do |t|
      t.integer :user_id
      t.string :name, null: false, default: ""
      t.string :description, null: false, default: ""
      t.string :location, null: false, default: ""
      t.string :link, null: false, default: ""
      t.timestamps
    end
  end
end
