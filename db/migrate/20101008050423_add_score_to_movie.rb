class AddScoreToMovie < ActiveRecord::Migration
  def self.up
    add_column :movies, :last_computed_score, :string
    Movie.all.each do |m|
      m.update_attributes(:last_computed_score => m.formatted_score)
    end
  end

  def self.down
    remove_column :movies, :last_computed_score
  end
end
