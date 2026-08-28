class AddRequestToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :request, :string
  end
end
