class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :project_id
      t.string :name
      t.timestamp :start_at
      t.timestamp :end_at
      t.string :cron_time
      t.time :timeout
      t.boolean :is_active

      t.timestamps
    end
  end
end
