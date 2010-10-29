class CreateTweets < ActiveRecord::Migration

  def self.up
    create_table :tweets do |t|
      t.string    :from_user
      t.string    :to_user
      t.string    :profile_image_url
      t.string    :text
      t.string    :source
      t.string    :metadata
      t.integer   :twitter_id,:limit => 8
      t.integer   :from_user_id,:limit => 8
      t.integer   :to_user_id,:limit => 8
      t.integer   :keyword_id
      t.string    :iso_language_code
      t.datetime  :created_on_twitter
      t.string    :category

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
