class FixDefaultValueOnResource < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:resources, :location, 'Texas (Statewide)')
  end
end
