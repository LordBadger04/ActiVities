class AddReferenceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :profile
  end
end
