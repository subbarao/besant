class AddMovieIdToTweet < ActiveRecord::Migration
  def self.up
    add_column :tweets, :movie_id, :integer
    add_column :keywords, :since_id, :string

    Tweet.connection.execute(%Q{
      update tweets inner join keywords on keywords.id = tweets.keyword_id
      set tweets.movie_id = keywords.movie_id
    })

    Tweet.connection.execute(%Q{
      update keywords set keywords.since_id = (select max(tweets.twitter_id)
      from tweets where tweets.keyword_id = keywords.id)
    })
  end

  def self.down
    remove_column :tweets, :movie_id
    remove_column :keywords, :since_id
  end
end
