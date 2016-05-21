require 'json'

# URI to the installed app root
host_uri = ENV["DASHING_URI"] || 'http://localhost:3030'

app = MusicApp.new()

post '/music/button' do
  button = params["button"]
  if button == "music_bruce"
#    send_event('music_info', { song_class: "song_big", artist: "", album: "", song: "Starting..." })
    app.playRadio("3145865860530746807")
    puts "Playing Bruce"
  elsif button == "music_u2"
#    send_event('music_info', { song_class: "song_big", artist: "", album: "", song: "Starting..." })
    app.playRadio("3153015765602842039")
    puts "Playing U2"
  elsif button == "music_greenDay"
    app.playRadio("3153016031890814391")
#    send_event('music_info', { song_class: "song_big", artist: "", album: "", song: "Starting..." })
    puts "Playing Green Day"
  elsif button == "music_killers"
#    send_event('music_info', { song_class: "song_big", artist: "", album: "", song: "Starting..." })
    app.playRadio("3153016203689506231")
    puts "Playing The Killers"
  elsif button == "music_playPause"
    app.playPause(0)
  else
    app.control(button)
  end
end

post '/music/refreshInfo' do
  app.refreshInfo()
end

SCHEDULER.every '3s', :first_in => 0 do |job|
  app.refresher()
end
