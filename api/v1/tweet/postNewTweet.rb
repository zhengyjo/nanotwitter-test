post PREFIX + '/tweets/new' do
  usr = session[:user_hash]
  msg = params[:tweet]['message']
  mentions = params[:tweet]['mention']
  hashtags = params[:tweet]['hashtag']
  new_tweet = Tweet.new(user: usr, message: msg)
  mentions_list = mentions.split(" ")
  hashtags_list = hashtags.split(" ")

  #byebug
  #hashtag_list =
  if new_tweet.save
    $redis.lpush('global', new_tweet)
    $redis.rpop('global') if $redis.llen('global') > 50
    mentions_list.each do |mention|
      if /([@.])\w+/.match(mention)
        term = mention[1..-1]
        if User.find_by_username(term)
          new_mention = Mention.new(username: term,tweet_id: new_tweet.id)
          @error = 'Mention could not be saved' if !new_mention.save
        end
      end
    end
    hashtags_list.each do |hashtag|
      if /([#.])\w+/.match(hashtag)
        term = hashtag[1..-1]
        if !Hashtag.find_by_tag(term)
          new_hashtag = Hashtag.new(tag: term)
          new_hashtag.save
        end
        new_hashtag = HashtagTweet.new(hashtag_id: Hashtag.find_by_tag(term).id,tweet_id: new_tweet.id) if Hashtag.exists?(tag:term)
        #byebug
        @error = 'Mention could not be saved' if !new_hashtag.save
      end
    end
    redirect PREFIX + '/'
  else
    @error = 'Tweet could not be saved'
    redirect PREFIX + '/'
  end
end
