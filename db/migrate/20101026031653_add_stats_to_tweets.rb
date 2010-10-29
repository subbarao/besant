class AddStatsToTweets < ActiveRecord::Migration
  def self.up
    add_column :tweets, :max_polarity,  :integer, :default => nil
    add_column :tweets, :min_polarity,   :integer, :default => nil
    add_column :tweets, :mean_polarity,  :integer, :default => nil

=begin
=end
  end

  def self.down
    remove_column :tweets, :max_polarity
    remove_column :tweets, :min_polarity
    remove_column :tweets, :mean_polarity
  end
end
