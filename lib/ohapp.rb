require 'net/https'
require 'json'

#
# Object grants REST-ful access to a ST SmartApp endpoint. This
# object also handles authorization with SmartThings.
# 
class OHApp
  OPENHAB_SERVER = "192.168.1.114"
  OPENHAB_PORT = 8080

  attr_reader :temperature, :currentConditions, :humidity, :pressure, :precipitation, :windSpeed, :temperatureLow, 
    :temperatureHigh, :weatherIcon, :weatherCode, :tomorrowTemperatureLow, :tomorrowTemperatureHigh, :tomorrowWeatherIcon, :tomorrowPrecipitation,
    :windSpeed, :windDirection, :windGust, :weatherObsTime, :sunrise, :sunset, :fanTexter, :rounder, :rounderPow, :thermoPow,
    :timeMin, :timeSec, :panicCount

  def initialize()
    #@endpoint = endpoint
    @temperature=0.0
    @currentConditions=""
    @humidity=0.0
    @pressure=0.0
    @precipitation=0
    @windSpeed=0
    @temperatureLow=0.0
    @temperatureHigh=0.0
    @weatherIcon=""
    @weatherCode=""
    @tomorrowTemperatureLow=0.0
    @tomorrowTemperatureHigh=0.0
    @tomorrowPrecipitation=0
    @tomorrowWeatherIcon=""
    @weatherObsTime=nil
    @windSpeed=0
    @windGust=0
    @windDirection=""
    @sunrise=nil
    @sunset=nil
    @panicCounter=0
    @timeSec=0
    @timeMin=0
  end

  # openHAB REST call
  def getState(itemID, data)
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/rest/items/#{itemID}?type=json"))
    puts response.body()
    response.body()
  end

  def fanPress()
    if (@rounder == 1)
      if (@fanTexter == 'Auto')
        puts "NIGGER"
        send_event('fan_state', { fanText: 'On' })
        sendCommand('fan_state', 'ON', 0)
        @fanTexter = 'On'
      else
        puts "FAGGOT"
        send_event('fan_state', { fanText: 'Auto' })
        sendCommand('fan_state', 'OFF', 0)
        @fanTexter = 'Auto'
      end
    else
      @rounder = 1
      data = getState('fan_state', 0)
      jsonData = JSON.parse(data)
      status = puts jsonData['state']
      if (status == 'ON')
        puts "CUNT"
        send_event('fan_state', { fanText: 'On' })
        sendCommand('fan_state', 'ON', 0)
        @fanTexter = 'On'
      else
        puts "MOTHERFUCKER"
        send_event('fan_state', { fanText: 'Auto' })
        sendCommand('fan_state', 'OFF', 0)
        @fanTexter = 'Auto'
      end
    end

#    puts "Testing radio start"

#    payload = {"jsonrpc" => "2.0" , "method" => "Addons.ExecuteAddon" , "params" => {"addonid" => "plugin.audio.pandoki" , "params" => {"play" => "3145865860530746807"}} , "id" => 1}.to_json
#    req = Net::HTTP::Post.new("/jsonrpc", initheader = { 'Content-Type' => 'application/json'})
#      req.basic_auth "jack", "24518000jJ"
#      req.body = payload
#      response = Net::HTTP.new(OPENHAB_SERVER, 2929).start {|http| http.request(req) }
#        puts response.body()

#    Net::HTTP.start(OPENHAB_SERVER, 2929) do |http|
#      http.use_ssl = false
#      req = Net::HTTP::Post.new("/jsonrpc?request={"jsonrpc%Q:%20%Q2.0%Q,%20%Qmethod%Q:%20%QAddons.ExecuteAddon%Q,%20%Qparams%Q:%20{%20%Qaddonid%Q:%20%Qplugin.audio.pandoki%Q,%20%Qparams%Q:{%Qplay%Q:%Q3145865860530746807%Q}},%20%Qid%Q:%201%20}")
#      req = Net::HTTP::Post.new("/jsonrpc?request={%Qjsonrpc%Q: %Q2.0%Q, %Qmethod%Q: %QAddons.ExecuteAddon%Q, %Qparams%Q: { %Qaddonid%Q: %Qplugin.audio.pandoki%Q, %Qparams%Q:{%Qplay%Q:%Q3145865860530746807%Q}}, %Qid%Q: 1 }")
#      req = Net::HTTP::Post.new("/jsonrpc?request={%22jsonrpc%22:%20%222.0%22,%20%22method%22:%20%22Addons.ExecuteAddon%22,%20%22params%22:%20{%22addonid%22:%20%20%22plugin.audio.pandoki%22,%20%22params%22:{%22play%22:%20%223145865860530746807%22}},%20%22id%22:%201%20}")
#      req = Net::HTTP::Post.new("/jsonrpc?request={%Qjsonrpc%Q:%Q2.0%Q,%Qmethod%Q:%QAddons.ExecuteAddon%Q,%Qparams%Q:{%Qaddonid%Q:%Qplugin.audio.pandoki%Q,%Qparams%Q:{%Qplay%Q:%Q3145865860530746807%Q}},%Qid%Q:1}")
#      req.basic_auth "jack", "24518000jJ"
#      response = http.request(req)
#      puts response.body()
#      response.body()
#    end

#Net::HTTP.start(host,cam_port) do |http|
#                req = Net::HTTP::Get.new(cam_url)
#                if cam_user != "None" ## if username for any particular camera is set to 'None' then assume auth not required.
#                        req.basic_auth cam_user, cam_pass
#                end
#                response = http.request(req)
#                open(new_file, "wb") do |file|
#                        file.write(response.body)
#                end

  end

  def sendCommand(itemID, newState, data)
    puts "[DEBUG] posting REST command: '/CMD?#{itemID}=#{newState}'"
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/CMD?#{itemID}=#{newState}"))
    puts response.body()
    response.body()
  end

  def panicPress()
    temp = @panicCounter
    time = Time.new
    case temp
    when 0
      temp = temp + 1
      @timeMin = time.min
      @timeSec = time.sec
    when 1..3
      if ((time.min == @timeMin) && ((time.sec - @timeSec) < 2))
        temp = temp + 1
      else
        temp = 0
      end
    when 4
      if ((time.min == timeMin) && ((time.sec - timeSec) < 2))
        sendCommand('panicButton', 'ON', 0)
        puts "AWWWWW SHIT somethins going down"
        temp = 0
      else 
        temp = 0
      end
    end
    @panicCounter = temp
  end

  def printTest(testNum)
    puts "'Something Happened!! (Test Number #{testNum})'"
  end

  def thermoPow()
    if (@rounderPow == 1)
      if (@thermoPower == 'On')
        send_event('thermoPow', { fanText: 'Off' })
        sendCommand('thermoPow', 'OFF', 0)
        @thermoPower = 'Off'
      else
        send_event('thermoPow', { fanText: 'On' })
        sendCommand('thermoPow', 'ON', 0)
        @thermoPower = 'On'
      end
    else
      @rounderPow = 1
      data = getState('thermoPow', 0)
      jsonData = JSON.parse(data)
      status = puts jsonData['state']
      if (status == 'ON')
        send_event('thermoPow', { fanText: 'ON' })
        @thermoPower = 'On'
      else
        send_event('thermoPow', { fanText: 'Off' })
        @thermoPower = 'Off'
      end
    end
  end


  def refreshWeather()
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/rest/items/Weather?type=json"))
    #puts response.body()
    data = JSON.parse(response.body())
    #puts data
    data["members"].each do |member|
      #p member["name"] + ": " + member["state"]
      value = member["state"]

      case member["name"]
        when "Weather_Conditions"
          @currentConditions = value
        when "Weather_Code"
          @weatherCode = value           
          @weatherIcon = (value.gsub "-","").gsub "day",""
        when "Weather_Temp_Max_0"
          @temperatureHigh = value.to_f.round               
        when "Weather_Temp_Min_0"
          @temperatureLow = value.to_f.round    
        when "Weather_Humidity"
          @humidity = value.to_f.round 
        when "Weather_Pressure"
          @pressure = value.to_f.round 
        when "Weather_Temp_Max_1"
          @tomorrowTemperatureHigh = value.to_f.round    
        when "Weather_Temp_Min_1"
          @tomorrowTemperatureLow = value.to_f.round    
        when "Sunrise_Time"
          @sunrise = value
        when "Sunset_Time"
          @sunset = value
        when "Weather_ObsTime"
          @weatherObsTime = value
        when "Weather_Code_1"
          @tomorrowWeatherIcon = (value.gsub "-","").gsub "day",""
        when "Weather_Precipitation"
          @precipitation = value.to_f.round
        when "Weather_Precipitation_1"
          @tomorrowPrecipitation=value.to_f.round           
        when "Weather_Wind_Speed"
          @windSpeed=value.to_f.round 
        when "Weather_Wind_Direction"
          @windDirection=value
        when "Weather_Wind_Gust"
          @windGust=value.to_f.round 
        when "Weather_Temperature"
          @temperature=value.to_f.round
      end
    end

    puts self.to_yaml
    data
  end

  def getWeather()


  end

  def getThermo()
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/rest/items/thermoTemp?type=json"))
    #puts response.body()
    data = JSON.parse(response.body())
    puts data
  end
    


    
  # SCHEDULER.every '5m', :first_in => 0 do |job|
  #   http = Net::HTTP.new("api.forecast.io", 443)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  #   response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  #   forecast = JSON.parse(response.body)  
  #   forecast_current_temp = forecast["currently"]["temperature"].round
  #   forecast_hour_summary = forecast["minutely"]["summary"]
  #   send_event('forecast', { temperature: "#{forecast_current_temp}&deg;", hour: "#{forecast_hour_summary}"})
  # end

#  private :refreshToken, :getEndpoint, :retrieveToken, :storeToken

end
