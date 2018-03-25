class HashtagTweet < ActiveRecord::Base
  validates :hashtag_id,presence:true
  validates :tweet_id,presence:true
  belongs_to :hashtag
  belongs_to :tweet

end
