require 'rubygems'
require 'json'
require 'websocket-client-simple'
require 'byebug'

ws = WebSocket::Client::Simple.connect 'ws://localhost:3000/cable'

channel_identifier = JSON.generate({ channel: "TestChannel" })

ws.on :message do |msg|
  data = JSON.parse(msg.data)

  if data['type'] == 'welcome'
    puts 'Got welcome message. Send subscription message'
    ws.send JSON.generate({ command: 'subscribe', identifier: channel_identifier })
  end

  if data['type'] == 'confirm_subscription' && data['identifier'] == channel_identifier
    puts 'Subscription successfully finished'
    puts 'Enter payload as a string in JSON format (example: {"temp":100,"power":50,"id":"123","test":true}): '
  end

  if data['message'] && data['identifier'] == channel_identifier
    print 'Server got JSON request with next high level keys: '
    puts JSON.parse(data['message']).keys.join(', ')
    print 'and with next values: '
    puts JSON.parse(data['message']).values.join(', ')
  end
end

ws.on :open do
  p 'Connection is open'
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p e
end

loop do
  data = { command: 'message',
           identifier: channel_identifier,
           data: JSON.generate(payload: STDIN.gets.strip)}
  ws.send JSON.generate(data)
end
