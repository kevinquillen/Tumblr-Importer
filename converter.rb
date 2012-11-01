require 'find'
require 'rubygems'
require 'nokogiri'
require 'date'
require 'oauth'

puts "What is your Tumblr blog hostname (example: myblog.tumblr.com)? Hostname: "
blog_hostname = gets.strip

puts "What is your Tumblr OAuth Consumer Key? This is used to establish OAuth connection. Consumer Key: "
consumer_key = gets.strip

puts "What is your Tumblr OAuth Consumer Secret Key? This is used to establish OAuth connection. Consumer Secret Key: "
consumer_secret = gets.strip

class TumblrImport
  attr_accessor :blog_hostname, :consumer_key, :consumer_secret, :request_token, :access_token

  def initialize (blog_hostname, consumer_key, consumer_secret)
    @blog_hostname = blog_hostname
    @consumer_key = consumer_key
    @consumer_secret = consumer_secret
    puts "Authenticating with Tumblr..."
    oauth_authorize
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
    title = post.css('h1.entry-title').text.to_s
    body = post.css('div.entry-content').text.to_s
    tags = post.css('span.categories a').map{|category| category.content}.join(', ')
    published = post.css('time')[0]['datetime']
    date = DateTime.parse(published)
    formatted_date = date.strftime('%Y-%m-%d %I:%M:%S GMT').to_s

    params = {
      :type => 'text',
      :title => title.to_s,
      :body => body.to_s,
      :tags => tags,
      :date => formatted_date.to_s
    }

    puts "Pushing \"#{title}\" published on #{published} up to Tumblr.."
    tumblr_push params
  end

  def tumblr_push params
    @access_token.post("http://api.tumblr.com/v2/blog/#@blog_hostname/post", params)

    # throttle the request so we don't overwhelm Tumblr API by hammering it with a large import of files
    sleep(2)
  end

  def oauth_authorize
    @consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret,
                                  :site => 'http://www.tumblr.com',
                                  :scheme => :header,
                                  :method => :post,
                                  :oauth_callback => 'http://localhost:8082/',
                                  :request_token_path => '/oauth/request_token',
                                  :access_token_path => '/oauth/access_token',
                                  :authorize_path => '/oauth/authorize')

    @request_token = @consumer.get_request_token
    puts "Please go here and authorize access to your account: #{@request_token.authorize_url}"
    puts "If you granted access, please enter the OAuth Verifier token from the URL:"
    @access_token = @request_token.get_access_token({:oauth_verifier => gets.strip})
  end
end

# Start import
TumblrImport.new(blog_hostname, consumer_key, consumer_secret)