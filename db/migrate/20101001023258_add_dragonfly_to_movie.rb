class AddDragonflyToMovie < ActiveRecord::Migration
  def self.up
    add_column :movies, :cover_image_uid, :string
    remove_column :movies, :poster
  end

  def self.down
    remove_column :movies, :cover_image_uid
    add_column :movies, :poster, :string
  end
end
