class AddFeaturedToTweet < ActiveRecord::Migration
  def self.up
    add_column :tweets, :featured, :boolean, :default => false
    Movie.all.each do | m |
      m.keywords.first.tweets.related.limit(5).update_all(:featured=>true)
    end
  end

  def self.down
    remove_column :tweets, :featured
  end
end
