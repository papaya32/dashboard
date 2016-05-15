require 'json'

host_uri = ENV["DASHING_URI"] || 'http://localhost:3030'

app = OHDash.new()

post '/openhab/addNum' do
  app.addPass(params['deviceId'])
end

post '/openhab/sendButton' do
  app.sendButton()
  app.sendPass()
end

post '/openhab/clearPass' do
  app.reset()
end
