class DeletingUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :status, :string, null: false, default: "active"
    change_column_default :users, :status, nil
    change_column :users, :email, :string, null: true, default: nil
  end
end
