class AddRequestIdToPatients < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :request_id, :integer
  end
end
