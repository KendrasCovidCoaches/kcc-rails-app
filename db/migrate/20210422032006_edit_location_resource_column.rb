class EditLocationResourceColumn < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:resources, :location, 'Texas')
  end
end
