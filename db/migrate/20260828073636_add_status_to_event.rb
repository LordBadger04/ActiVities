class AddStatusToEvent < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :status, :string, default: "Coming"
  end
end
