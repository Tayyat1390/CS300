class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :data
      t.integer :state
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
