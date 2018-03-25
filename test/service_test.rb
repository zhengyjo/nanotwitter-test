require 'minitest/autorun'
require 'rack/test'
require 'rake/testtask'
require_relative '../service.rb'
require_relative '../erb_constants.rb'
require_relative '../prefix.rb'

# These tests are not done yet! They still need to be filled out as we think of new functionality.

class ServiceTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @jim = User.create({username: 'jim', password: 'abc', email: 'jim@jim.com'})
    @bob = User.create({username: 'bob', password: 'abc', email: 'bob@bob.com'})
  end

  def teardown
    @jim.destroy
    @bob.destroy
    not_logged_in
  end

  def logged_in
    get PREFIX + '/', {}, { 'rack.session' => {user_id: @jim.id, user_hash: @jim, username: @jim.username} }
  end

  def not_logged_in
    get PREFIX + '/', {}, { 'rack.session' => {username: nil} }
  end

  def test_home
    not_logged_in
    assert last_response.ok? && (last_response.body.include? 'Login to nanoTwitter')
  end

  def test_login_page
    not_logged_in
    get PREFIX + '/login'
    assert last_response.ok? && (last_response.body.include? 'Login to Nanotwitter') && (last_response.body.include? `<form action="#{PREFIX}/login" method="POST">`)
  end

  def test_registration_page
    not_logged_in
    get PREFIX + '/user/register'
    assert last_response.ok? && (last_response.body.include? 'Register in Nanotwitter')
  end

  def test_login_correctly
    not_logged_in
    get PREFIX + '/login'
    param = { 'username' => 'jim', 'password' => 'abc' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
  end

  def test_home_logged_in
    logged_in
    get PREFIX + '/'
    assert last_response.ok?
    assert last_response.body.include?('jim')
  end

  def test_login_incorrectly
    get PREFIX + '/login'
    param = { 'username' => 'obviously wrong', 'password' => 'wrong' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.body.include?("Wrong password or username.")
  end

  def test_logout
    logged_in
    assert last_response.ok?
    assert last_response.body.include?('jim')
    post PREFIX + '/logout'
    get PREFIX + '/'
    assert last_response.ok?
    assert last_response.body.include?("Login to nanoTwitter")
  end

  def test_tweet
    logged_in
    post PREFIX + '/tweets/new', {:tweet => {message: "I am a test message", mention: '', hashtag: ''}}
    get PREFIX + '/'
    assert last_response.ok?
    assert Tweet.find_by_message('I am a test message')
    Tweet.find_by_message('I am a test message').destroy
  end

  def test_user_page
    logged_in
    get PREFIX + '/user/' + @jim.id.to_s
    assert last_response.ok?
    assert last_response.body.include?('jim')
  end

  def test_user_timeline
    logged_in
    get PREFIX + '/user/' + @jim.id.to_s + '/timeline'
    assert last_response.ok?
    assert last_response.body.include?("jim")
  end

  def test_user_followers
    logged_in
    get PREFIX + '/user/' + @jim.id.to_s + '/followers'
    assert last_response.ok?
    assert last_response.body.include?('Followers')
  end

  def test_user_leaders
    logged_in
    get PREFIX + '/user/' + @jim.id.to_s + '/leaders'
    assert last_response.ok?
    assert last_response.body.include?('Leaders')
  end

  def test_follow
    logged_in
    post PREFIX + '/user/' + @bob.id.to_s + '/follow'
    assert @bob.followers.include?(@jim)
    assert @jim.leaders.include?(@bob)
  end

  def test_unfollow
    logged_in
    @jim.leaders.push(@bob)
    assert @bob.followers.include?(@jim)
    assert @jim.leaders.include?(@bob)
    post PREFIX + '/user/' + @bob.id.to_s + '/unfollow'
    assert !@bob.followers.include?(@jim)
    assert !@jim.leaders.include?(@bob)
  end

  def test_search_basic
    logged_in
    tweet = Tweet.create(message: 'lol', user_id: @bob.id)
    get PREFIX + '/search', {search: 'lol'}
    assert last_response.ok?
    assert last_response.body.include?('lol')
    assert last_response.body.include?('jim')
    tweet.destroy
  end
end
