class CreateMovies < ActiveRecord::Migration
  def self.up
    create_table :movies do |t|
      t.string :name
      t.string :cast
      t.text :plot
      t.string :director
      t.string :banner
      t.string :producer
      t.string :music_director
      t.text :plot
      t.string :poster
      t.date :released_on

      t.timestamps
    end
  end

  def self.down
    drop_table :movies
  end
end
