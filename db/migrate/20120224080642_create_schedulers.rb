class CreateSchedulers < ActiveRecord::Migration
  def change
    create_table :schedulers do |t|
      t.integer :task_id
      t.timestamp :start_at
      t.boolean :is_started

      t.timestamps
    end
  end
end
