class Hashtag < ActiveRecord::Base
  validates :tag,presence:true
  has_many :tweets, through: :hashtag_tweets

end
