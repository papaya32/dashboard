require 'json'

host_uri = ENV["DASHING_URI"] || 'http://localhost:3030'

app = OHDash.new()

post '/openhab/tempChange' do
  app.tempChange(params['direction'])
end

post '/openhab/fanText' do
  app.fanText(params['mode'])
end

post '/openhab/roomTemp' do
  puts(params['temp'])
  app.roomTemp(params['temp'])
end
