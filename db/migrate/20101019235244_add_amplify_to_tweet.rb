class AddAmplifyToTweet < ActiveRecord::Migration
  def self.up
    add_column :tweets, :open_amplify, :text
  end

  def self.down
    remove_column :tweets, :open_amplify
  end
end
