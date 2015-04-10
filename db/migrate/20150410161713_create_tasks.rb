class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.integer :interval, default: 3600
      t.integer :pid
      t.string :scraper, default: 'SportsScraper'
      t.string :status, default: Task.statuses[:brand_new]

      t.timestamps null: false
    end
  end
end
