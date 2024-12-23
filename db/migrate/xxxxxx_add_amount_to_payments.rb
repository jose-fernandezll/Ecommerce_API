class AddAmountToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :amount, :integer
  end
end
