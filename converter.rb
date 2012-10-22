require 'find'
require 'rubygems'
require 'nokogiri'
require 'oauth'
require 'json'

class TumblrImport
  attr_accessor :api_key

  def initialize (consumer_key, consumer_secret)
    @consumer_key = api_key
    @consumer_secret = consumer_secret
                 oauth_request_token
    puts "Searching for .html posts to send to Tumblr..."
    recurse_directories
  end

  def recurse_directories
    count = 0

    Find.find(Dir.getwd) do |file|
      if !File.directory? file and File.extname(file) == '.html'
        count += 1
        parse_file file
      end
    end

    puts "#{count} posts were parsed and pushed to Tumblr. Go check!"
  end

  def parse_file file
    post = Nokogiri::HTML(open(file))
    # this needs work... cant quite figure out how to snatch the datetime attribute from a <time> tag yet
    # published = post.css('time:first-child').map {|time| time.content}
    title = post.css('h1.entry-title').text
    body = post.css('div.entry-content').text
    tags = post.css('span.categories a').map{|category| category.content}.join(', ')
    tumblr_push title, body, tags
  end

  def tumblr_push title, body, tags

  end

  def oauth_request_token
    @consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret,
                                  :site => 'http://www.tumblr.com/',
                                  :request_token_path => '/oauth/request_token',
                                  :access_token_path => '/oauth/access_token',
                                  :authorize_path => '/oauth/authorize')

    @request_token = @consumer.get_request_token(:oauth_callback => @callback_url)
    @request_token.authorize_url(:oauth_callback => 'http://www.tumblr.com/api/authenticate')
    @access_token = @request_token.get_access_token

    test = @access_token.get('http://api.tumblr.com/v2/blog/kevinquillen.tumblr.com/info')

    #access_token = OAuth::AccessToken.new(consumer)

    #response = access_token.request(:get, "http://api.tumblr.com/v2/blog/kevinquillen.tumblr.com/info")
    #response = JSON.parse(response)
    puts test
    exit
  end
end

puts "What is your Tumblr OAuth Consumer Key? This is used to establish OAuth connection. Consumer Key: "
consumer_key = gets.strip

puts "What is your Tumblr consumer secret key? This is used to establish OAuth connection. Consumer Secret Key: "
consumer_secret = gets.strip

# Start import
TumblrImport.new(consumer_key, consumer_secret)
