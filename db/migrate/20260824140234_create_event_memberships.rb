class CreateEventMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :event_memberships do |t|
      t.boolean :is_admin
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
