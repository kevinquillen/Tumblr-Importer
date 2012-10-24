require 'find'
require 'rubygems'
require 'nokogiri'
require 'oauth'

class TumblrImport
  attr_accessor :consumer_key, :consumer_secret, :request_token

  def initialize (consumer_key, consumer_secret)
    @consumer_key = consumer_key
    @consumer_secret = consumer_secret
    puts "Authenticating with Tumblr..."
    oauth_request_token
    # if request token is bad, stop here
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
    published = post.css('time:first-child').text
    title = post.css('h1.entry-title').text
    body = post.css('div.entry-content').text
    tags = post.css('span.categories a').map{|category| category.content}.join(', ')
    tumblr_push title, body, tags, published
  end

  def tumblr_push title, body, tags, published
    # this will push our arguments as a Tumblr post via /post of Tumblr API
  end

  def oauth_request_token
    @consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret,
                                  :site => 'http://www.tumblr.com/',
                                  :scheme => :header,
                                  :method => :post,
                                  :request_token_path => '/oauth/request_token',
                                  :access_token_path => '/oauth/access_token',
                                  :authorize_path => '/oauth/authorize')

    @request_token = @consumer.get_request_token
  end
end

puts "What is your Tumblr OAuth Consumer Key? This is used to establish OAuth connection. Consumer Key: "
consumer_key = gets.strip

puts "What is your Tumblr OAuth Consumer Secret Key? This is used to establish OAuth connection. Consumer Secret Key: "
consumer_secret = gets.strip

# Start import
TumblrImport.new(consumer_key, consumer_secret)
