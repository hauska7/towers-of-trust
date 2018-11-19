class AddStatusToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :status, :string, null: false
  end
end
