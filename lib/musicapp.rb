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

  def playRadio(playlist)
    payload = {"jsonrpc" => "2.0" , "method" => "Addons.ExecuteAddon" , "params" => {"addonid" => "plugin.audio.pandoki" , "params" => {"play" => "#{playlist}"}} , "id" => 1}.to_json
    temp = {"song_class" => "song_big", "artist_class" => "artist_big", "artist" => " ", "album" => " ", "song" => "Starting Music..."}.to_json
    send_event("music_info", { song_class: "song_big", artist_class: "artist_big", album: " ", artist: " ", song: "Starting Music..." })
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
    if attempt == "pause"
      json = JSON.parse(response.body())
      newState = json["result"]["speed"]
      if newState == 0
        playPause(2)
        @globalControl = 0
      else
        playPause(1)
        @globalControl = 1
      end
    elsif attempt == "control"
      json = JSON.parse(payload)
      temp = json["method"]
      if temp == "Player.Stop"
        send_event('music_info', { song_class: "song_big", artist: "", album: "", song: "Stopped" })
        @globalControl = 0
      end
    elsif attempt == "play"
#      send_event('music_info', { song_class: "song_big", artist: "", album: "", song: "Starting Music..." })
      sleep 1
      @globalControl = 1
      loop do
        sleep 1
        payload = {"jsonrpc" => "2.0", "method" => "Player.GetItem", "params" => {"properties" => ["title", "album", "artist", "duration"], "playerid" => 0}, "id" => "AudioGetItem"}.to_json
        req = Net::HTTP::Post.new("/jsonrpc", initheader = { 'Content-Type' => 'application/json'})
          req.basic_auth Kodi_User, Kodi_Pass
          req.body = payload
          response = Net::HTTP.new(Kodi_Server, Kodi_Port).start {|http| http.request(req) }
        json = JSON.parse(response.body())
        break if !(json["result"]["item"]["type"] == "unknown")
      end
    elsif attempt == "musicInfo"
      json = JSON.parse(response.body())
      artist = json["result"]["item"]["artist"][0]
      album = json["result"]["item"]["album"]
      duration = json["result"]["item"]["duration"]
      song = json["result"]["item"]["title"]

#      puts artist, song, album, duration

      for i in 1..3
        if i == 1
          if (song.length < 20)
            prior = 3
            songSize = "song_big"
          elsif (song.length < 28)
            prior = 2
            songSize = "song_medium"
          else
            prior = 1
            songSize = "song_small"
          end
        end
        i == 2 ? temp = album.length : temp = artist.length
        if i == 2
          if (temp < 30)
            prior2 = 3
            artistSize = "artist_big"
          elsif (temp < 40)
            prior2 = 2
            artistSize = "artist_medium"
          else
            prior2 = 1
            artistSize = "artist_small"
          end
        end
        if i == 3
          if (temp < 30)
            prior3 = 3
            artistSize = "artist_big"
          elsif (temp < 40)
            prior3 = 2
            artistSize = "artist_medium"
          else
            prior3 = 1
            artistSize = "artist_small"
          end
        end
      end
#      if (prior == 1) || (prior2 == 1) || (prior3 == 1)
#        artistSize = "artist_small"
#        songSize = "song_small"
#      elsif ((prior == 1) || (prior2 == 1) || (prior3 == 1)) && (prior == 1)
#        artistSize = "artist_medium"
#        songSize = "song_small"
#      elsif (prior == 2) || (prior2 == 2) || (prior3 == 2)
#        artistSize = "artist_medium"
#        songSize = "song_medium"
#      else
#        artistSize = "artist_big"
#        songSize = "song_big"
#      end
      counter = 0

#      puts artistSize, songSize
      send_event('music_info', { artist_class: artistSize, song_class: songSize, song: song, album: album, artist: artist })

      @currentDuration = duration

    elsif attempt == "volumeInfo"
      json = JSON.parse(response.body())
      volume = json["result"]["volume"]
      @volume = volume
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
      payload = {"jsonrpc" => "2.0", "method" => "Player.GoTo", "params" => {"playerid" => 0, "to" => "next"}, "id" => 1}.to_json
      kodiExecute(payload, "skip")
      refreshInfo()
    elsif button == "music_back"
      payload = {"jsonrpc" => "2.0", "method" => "Player.GoTo", "params" => {"playerid" => 0, "to" => "previous"}, "id" => 1}.to_json
      kodiExecute(payload, "skip")
      refreshInfo()
    elsif button == "music_stop"
      func = "Stop"
      payload = {"jsonrpc" => "2.0", "method" => "Player.#{func}", "params" => { "playerid" => 0 }, "id" => 1}.to_json
      send_event('music_info', { song_class: "song_big", artist: "", album: "", song: "Stopped" })
      @globalControl = 0
      kodiExecute(payload, "control")
    elsif (button == "music_volumeUp") || (button == "music_volumeDown")
      volumeControl(button)
      refreshInfo()
    end
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

  def refresher()
    if (@globalControl == 1)
      refreshInfo()
    end
  end

end
