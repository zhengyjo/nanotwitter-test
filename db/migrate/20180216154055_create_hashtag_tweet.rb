class CreateHashtagTweet < ActiveRecord::Migration[5.1]
  def change
    create_table :hashtag_tweets do |t|
      t.integer :hashtag_id
      t.integer :tweet_id

    end
  end
end
