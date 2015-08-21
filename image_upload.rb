#!/usr/bin/env ruby
# testing out image upload to twitter

require 'yaml'
require 'json'
require 'oauth'
require 'twitter'

cfgfile = 'auth.cfg'
imagefile = ARGV[0]
cnf = YAML::load(File.open(cfgfile))

client = Twitter::REST::Client.new do |config|
  config.consumer_key       = cnf['crcbot']['con_key']
  config.consumer_secret    = cnf['crcbot']['con_sec']
  config.access_token        = cnf['crcbot']['o_tok']
  config.access_token_secret = cnf['crcbot']['o_tok_sec']
end

media_id = client.upload File.new imagefile

puts media_id
client.update "testing automated image upload+post", {media_ids: media_id}
