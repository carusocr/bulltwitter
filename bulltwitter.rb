#!/usr/bin/env ruby
=begin 

BullTwitter will listen for the map page's creation of a websocket. Once it's 
found it, it will then start listening for events from the bulltwitter map and
call the tweet method when a message is received.

=end

require 'em-websocket'
require 'yaml'
require 'json'
require 'oauth'
require 'twitter'

cfgfile = 'auth.cfg'
cnf = YAML::load(File.open(cfgfile))
#set up Twitter client
$client = Twitter::REST::Client.new do |config|
  config.consumer_key       = cnf['crcbot']['con_key']
  config.consumer_secret    = cnf['crcbot']['con_sec']
  config.access_token        = cnf['crcbot']['o_tok']
  config.access_token_secret = cnf['crcbot']['o_tok_sec']
end

def bulltweet(lat,lng,status)
  $client.update status, {lat: lat, long: lng}
end

def bulltweet_with_image(lat,lng,status,imgfile)
  media_id = $client.upload File.new imgfile
  $client.update status, {lat: lat, long: lng, media_ids: media_id}
end

EM.run {
  EM::WebSocket.run(:host => "127.0.0.1", :port => 8567) do |ws|
    ws.onopen do
      puts "WebSocket opened"
    end
    ws.onclose do
      ws.close(code = nil, body = nil)
      puts "WebSocket closed"
      exit
    end
    ws.onmessage do |msg|
      # check for coords in parens + string
      if msg =~ /^(?!IMG)\(-?\d{1,3}\.\d+, -?\d{1,3}\.\d+\)/
        puts "zug #{msg}\n"
        lat,lng,status = msg.match(/\((-?\d{1,3}\.\d+), (-?\d{1,3}\.\d+)\)(.+)$/).captures
        bulltweet(lat,lng,status)
      elsif msg =~ /IMG/
        puts "got #{msg}\n"
        imgfile,lat,lng,status = msg.match(/IMG(.+)\((-?\d{1,3}\.\d+), (-?\d{1,3}\.\d+)\)(.+)$/).captures
        puts "sending #{imgfile} and status #{status}\n"
        bulltweet_with_image(lat,lng,status,imgfile) 
      else
        puts "Got unintelligible command, please resend."
      end
    end
  end
}

