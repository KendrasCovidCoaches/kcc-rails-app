class AddInfoToPatients < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :f_name, :string
    add_column :patients, :l_name, :string
    add_column :patients, :email, :string
    add_column :patients, :phone, :string
  end
end
