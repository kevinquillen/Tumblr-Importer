require 'find'
require 'rubygems'
require 'nokogiri'
require 'oauth'

class TumblrImport
  attr_accessor :count, :api_key

  def initialize
    @count = 0
    @api_key = 'YOURAPIKEYHERE'

    puts "Searching for .html posts to send to Tumblr..."
    recurse_directories
  end

  def recurse_directories
    Find.find(Dir.getwd) do |file|
      if !File.directory? file and File.extname(file) == '.html'
        @count += 1
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

  def tumblr_push title, body, published

  end
end

# Start import
TumblrImport.new()
