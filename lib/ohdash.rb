require 'net/https'
require 'json'

class OHDash
  OPENHAB_SERVER = "192.168.1.114"
  OPENHAB_PORT = 8080

  attr_reader :pass, :passFinal

  def initialize()
    @pass=""
    @passFinal=""
  end

  def addPass(addNum)
    @pass = pass + addNum
  end

  def sendButton()
    @passFinal = pass
  end

  def sendPass()
    puts "'Sending Password: #{@pass}'"
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/CMD?passWord=#{@pass}"))
    puts response.body()
    response.body()
    @pass = ""
  end

  def reset()
    @pass = ""
    puts "Reseting Password Variable"
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/CMD?passWord=#{@pass}"))
    puts response.body()
    response.body()
  end

  def tempChange(direction)
    puts "'#{direction}-ing the temperature'"
    if (direction == 'increase')
      value = 'ON'
    else
      value = 'OFF'
    end
    http = Net::HTTP.new(OPENHAB_SERVER, OPENHAB_PORT)
    http.use_ssl = false
    response = http.request(Net::HTTP::Get.new("/CMD?changeTemp=#{value}"))
    puts response.body()
    response.body()
  end

  def fanText(mode)
    puts "'Fan now in #{mode} mode'"
    if (mode == '1')
      send_event('fan_state', { fanText: 'Off' })
    elsif (mode == '2')
      send_event('fan_state', { fanText: 'On' })
    else
      send_event('fan_state', { fanText: 'Auto' })
    end
  end

  def roomTemp(temp)
    puts "'room temp update to #{temp}'"
    send_event('roomTemp', { temperature: temp })
  end

end
