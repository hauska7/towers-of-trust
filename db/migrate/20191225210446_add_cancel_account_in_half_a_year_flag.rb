class AddCancelAccountInHalfAYearFlag < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :cancel_account_on, :datetime, null: true
  end
end
