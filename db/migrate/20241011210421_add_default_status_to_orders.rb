class AddDefaultStatusToOrders < ActiveRecord::Migration[7.0]
  def change
    change_column :orders, :status, :string, default: 'pending'
  end
end
