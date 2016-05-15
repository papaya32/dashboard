require 'net/https'
require 'json'

class MusicApp
  Kodi_Server = "192.168.1.114"
  Kodi_Port = 2929
  Kodi_User = "jack"
  Kodi_Pass = "24518000jJ"

  attr_reader :playState, :currentDuration, :volume, :globalControl

  def initialize()
    @playState = "play"
    @currentDuration = 0
    @volume = 0
    @globalControl = 0
  end

  def playBruce()
    puts "Playing Bruce Springsteen"
    playRadio("3145865860530746807")
  end

  def playRadio(playlist)
    payload = {"jsonrpc" => "2.0" , "method" => "Addons.ExecuteAddon" , "params" => {"addonid" => "plugin.audio.pandoki" , "params" => {"play" => "#{playlist}"}} , "id" => 1}.to_json
    kodiExecute(payload, "play")
    refreshInfo()
  end

  def playPause(newState)
    if newState == 1
      send_event('music_playPause', { icon: 'pause' })
      @playState = "pause"
    elsif newState == 2
      send_event('music_playPause', {icon: 'play' })
      @playState = "play"
    else
      payload = {"jsonrpc" => "2.0" , "method" => "Player.PlayPause" , "params" => { "playerid" => 0 }, "id" => 1}.to_json
      kodiExecute(payload, "pause")
    end
  end

  def kodiExecute(payload, attempt)
    req = Net::HTTP::Post.new("/jsonrpc", initheader = { 'Content-Type' => 'application/json'})
      req.basic_auth Kodi_User, Kodi_Pass
      req.body = payload
      response = Net::HTTP.new(Kodi_Server, Kodi_Port).start {|http| http.request(req) }
        puts response.body()
    if attempt == "pause"
      puts "POINT 1"
      json = JSON.parse(response.body())
      newState = json["result"]["speed"]
      puts "POINT 4" 
      if newState == 0
        playPause(2)
      else
        playPause(1)
      end
    elsif attempt == "control"
      json = JSON.parse(payload)
      temp = json["method"]
      if temp == "Player.Stop"
        send_event('music_info', { artist: "", album: "", song: "Stopped", song_class: "song_medium" })
      end
    elsif attempt == "play"
      send_event('music_info', {artist: "", album: "", song: "Starting Music...", song_class: "song_medium" })
      counter = 0
      loop do
        counter += 1
        puts "Counter is: ", counter
        sleep 1
        payload = {"jsonrpc" => "2.0", "method" => "Player.GetItem", "params" => {"properties" => ["title", "album", "artist", "duration"], "playerid" => 0}, "id" => "AudioGetItem"}.to_json
        req = Net::HTTP::Post.new("/jsonrpc", initheader = { 'Content-Type' => 'application/json'})
          req.basic_auth Kodi_User, Kodi_Pass
          req.body = payload
          response = Net::HTTP.new(Kodi_Server, Kodi_Port).start {|http| http.request(req) }
            puts response.body()
        json = JSON.parse(response.body())
        puts json["result"]["item"]["type"]
        break if !((json["result"]["item"]["type"] == "unknown") || !(counter == 10) || (json["result"]["item"]["artist"][0] == "Pandoki"))
      end
    elsif attempt == "musicInfo"
      json = JSON.parse(response.body())
      @globalControl = 1
      artist = json["result"]["item"]["artist"][0]
      album = json["result"]["item"]["album"]
      duration = json["result"]["item"]["duration"]
      song = json["result"]["item"]["title"]

      puts artist, song, album, duration

      for i in 1..3
        if i == 1
          if (song.length < 20)
            prior = 3
          elsif (song.length < 28)
            prior = 2
          else
            prior = 1
          end
        end
        i == 2 ? temp = album.length : temp = artist.length
        if i == 2
          if (temp < 30)
            prior2 = 3
          elsif (temp < 40)
            prior2 = 2
          else
            prior2 = 1
          end
        end
        if i == 3
          if (temp < 30)
            prior3 = 3
          elsif (temp < 40)
            prior3 = 2
          else
            prior3 = 1
          end
        end
      end
      if (prior == 1) || (prior2 == 1) || (prior3 == 1)
        artistSize = "artist_small"
        songSize = "song_small"
      elsif ((prior == 1) || (prior2 == 1) || (prior3 == 1)) && (prior == 1)
        artistSize = "artist_medium"
        songSize = "song_small"
      elsif (prior == 2) || (prior2 == 2) || (prior3 == 2)
        artistSize = "artist_medium"
        songSize = "song_medium"
      else
        artistSize = "artist_big"
        songSize = "song_big"
      end
      counter = 0

      puts artistSize, songSize

#      send_event('music_info', { artist_class: artistSize })
#      send_event('music_info', { song_class: songSize })
      send_event('music_info', { artist_class: artistSize, song_class: songSize, song: song, album: album, artist: artist })

      @currentDuration = duration

    elsif attempt == "volumeInfo"
      json = JSON.parse(response.body())
      volume = json["result"]["volume"]
      @volume = volume
      puts volume
      send_event('music_volume', { title: "#{volume}%" })

    end
  end

  def refreshInfo()
    payload = {"jsonrpc" => "2.0", "method" => "Player.GetItem", "params" => {"properties" => ["title", "album", "artist", "duration"], "playerid" => 0}, "id" => "AudioGetItem"}.to_json
    payload2 = {"jsonrpc" => "2.0", "method" => "Application.GetProperties", "params" => {"properties" => ["volume"]}, "id" => 1}.to_json
    kodiExecute(payload, "musicInfo")
    kodiExecute(payload2, "volumeInfo")
    
  end

  def control(button)
    if button == "music_next"
      func = "Next"
      refreshInfo()
    elsif button == "music_back"
      func = "Previous"
      refreshInfo()
    elsif button == "music_stop"
      func = "Stop"
      send_event('music_info', { song_class: "song_medium", artist: "", album: "", song: "Stopped" })
    elsif (button == "music_volumeUp") || (button == "music_volumeDown")
      volumeControl(button)      
      refreshInfo()
    end
    payload = {"jsonrpc" => "2.0", "method" => "Player.#{func}", "params" => { "playerid" => 0 }, "id" => 1}.to_json
    puts payload
    kodiExecute(payload, "control")
  end

  def volumeControl(button)
    volume = @volume
    if button == "music_volumeDown"
      if (volume >= 5)
        volume = volume - 5
      else
        volume = 0
      end
    else
      if (volume <= 95)
        volume = volume + 5
      else
        volume = 100
      end
    end
    @volume = volume
    payload = {"jsonrpc" => "2.0", "method" => "Application.SetVolume", "params" => {"volume" => volume }, "id" => 1}.to_json
    kodiExecute(payload, "volumeSet")
    refreshInfo()
  end

  SCHEDULER.every '5s' do
    if (@globalControl == 1)
      refreshInfo()
    end
  end
end
