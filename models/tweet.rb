class Tweet < ActiveRecord::Base
  validates :message,presence:true
  belongs_to :user
  has_many :users, through: :mentions
  has_many :hashtags,through: :hashtag_tweets


end
