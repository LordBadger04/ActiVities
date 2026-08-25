class CreateUserActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :user_activities do |t|
      t.string :level
      t.references :profile, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
