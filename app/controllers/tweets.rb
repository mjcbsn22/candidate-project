get '/tweets' do
  tweets = get_objects( Tweet.all )

  output('tweet', tweets.as_json)  
end