#!/usr/bin/env ruby
=begin

General idea of this app is that I can make a tweet that's tagged to a geolocation
other than my actual location. Ideally the interface will be a Google Maps view, and I
can zoom in, click a location, and select a Make Tweet From Here' button to make 
tweet that displays as being from that lat+long. 

First goal is to generate a tweet with artificial geotagged info. 

Second is to add a map interface.

=end

require 'twitter'
require 'yaml'
require 'json'
require 'oauth'

cfgfile = 'auth.cfg'
#status = ARGV[0]

cnf = YAML::load(File.open(cfgfile))

#client = Twitter::REST::Client.new do |config|
#  config.consumer_key       = cnf['crcbot']['con_key']
#  config.consumer_secret    = cnf['crcbot']['con_sec']
#  config.access_token        = cnf['crcbot']['o_tok']
#  config.access_token_secret = cnf['crcbot']['o_tok_sec']
#end

con_key       = cnf['crcbot']['con_key']
con_sec    = cnf['crcbot']['con_sec']
access_token        = cnf['crcbot']['o_tok']
access_token_secret = cnf['crcbot']['o_tok_sec']

#client.update(status)

#testing straight post
consumer = OAuth::Consumer.new(con_key,con_sec, :site => "http://api.twitter.com", :scheme => :header)
access_token = OAuth::AccessToken.from_hash(consumer, :oauth_token => access_token, :oauth_token_secret => access_token_secret)
#this worked
access_token.request(:post, "https://api.twitter.com/1.1/statuses/update.json", {"Content-Type" => "application/json", "status"=>"foo"})
