class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.integer :age
      t.text :description
      t.string :first_name
      t.string :last_name
      t.string :location
      t.string :username
      t.string :gender
      t.string :language
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
