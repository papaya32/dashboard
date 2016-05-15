require 'json'

# URI to the installed app root
host_uri = ENV["DASHING_URI"] || 'http://localhost:3030'

app = MusicApp.new()

post '/music/button' do
  button = params["button"]
  if button == "bruce"
    app.playBruce()
  elsif button == "music_playPause"
    app.playPause(0)
  else
    app.control(button)
  end
end

post '/music/refreshInfo' do
  app.refreshInfo()
end
