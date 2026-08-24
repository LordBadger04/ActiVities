class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :name
      t.string :genre

      t.timestamps
    end
  end
end
