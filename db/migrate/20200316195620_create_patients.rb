class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.integer :user_id
      t.integer :project_id
      t.timestamps
    end
  end
end
