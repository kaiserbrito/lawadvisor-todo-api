class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string :description
      t.boolean :done, default: false
      t.integer :position

      t.timestamps
    end
  end
end
