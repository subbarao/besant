class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :number_of_requests
      t.text  :message

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
