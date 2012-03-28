class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :task_id
      t.string :result
      t.boolean :is_timeout
      t.boolean :is_error

      t.timestamps
    end
  end
end
