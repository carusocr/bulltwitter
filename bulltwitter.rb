#!/usr/bin/env ruby
=begin 

Socket.rb will listen for the map page's creation of a websocket. Once it's 
found it, it will then start listening for events from the bulltwitter map and
call the tweet script when a message is received.

=end

require 'em-websocket'
require 'bunny'
require 'yaml'
require 'json'
require 'oauth'

cfgfile = 'auth.cfg'
cnf = YAML::load(File.open(cfgfile))
$con_key       = cnf['crcbot']['con_key']
$con_sec    = cnf['crcbot']['con_sec']
$access_token        = cnf['crcbot']['o_tok']
$access_token_secret = cnf['crcbot']['o_tok_sec']

def bulltweet(lat,lng,status)

  consumer = OAuth::Consumer.new($con_key,$con_sec, :site => "http://api.twitter.com", :scheme => :header)
  access_token = OAuth::AccessToken.from_hash(consumer, :oauth_token => $access_token, :oauth_token_secret => $access_token_secret)
  access_token.request(:post, "https://api.twitter.com/1.1/statuses/update.json", {"Content-Type" => "application/json", "status"=>"#{status}", "lat"=>lat, "long"=>lng})

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
      if msg =~ /\(-?\d{1,3}\.\d+, -?\d{1,3}\.\d+\)/
        puts "got #{msg}\n"
        lat,lng,tweet = msg.match(/\((-?\d{1,3}\.\d+), (-?\d{1,3}\.\d+)\)(.+)$/).captures
        bulltweet(lat,lng,tweet)
      else
        puts "Got unintelligible command, please resend."
      end
    end
  end
}

