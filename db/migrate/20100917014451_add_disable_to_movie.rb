class AddDisableToMovie < ActiveRecord::Migration
  def self.up
    add_column :movies,:disabled, :boolean, :default => true
    Movie.update_all(:disabled => false)
  end

  def self.down
    remove_column :movies, :disabled
  end
end
