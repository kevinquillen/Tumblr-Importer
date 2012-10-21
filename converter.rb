require 'find'
require 'rubygems'
require 'nokogiri'

# set oauth key for tumblr
# set tumblr API URL

def initialize
  puts "Searching for .html posts to send to Tumblr..."
  recurse_directories
end

# recurse through the script directory and find .html posts to send to Tumblr
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

# Parse the .html file for the Tumblr API
def parse_file file
  post = Nokogiri::HTML(open(file))
  # this needs work... cant quite figure out how to snatch the datetime attribute from a <time> tag yet
  # published = post.css('time:first-child').map {|time| time.content}
  title = post.css('h1.entry-title').text
  body = post.css('div.entry-content').text
  tags = post.css('span.categories a').map{|category| category.content}.join(', ')
  tumblr_push title, body, tags
end

# Push data to Tumblr
def tumblr_push title, body, published
  # oauth authenticate
  # POST to /post
end

# Start script
initialize