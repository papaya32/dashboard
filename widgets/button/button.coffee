class Dashing.Button extends Dashing.ClickableWidget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # Fired when you receive data
    # You could do something like have the widget flash each time data comes in by doing:
    # $(@node).fadeOut().fadeIn()
    $.post '/tester/data',
      dataid: data


  # Any attribute that has the 'Dashing.AnimatedValue' will cause the number to animate when it changes. 
  @accessor 'current', Dashing.AnimatedValue
  @accessor 'currentIcon', Dashing.AnimatedValue

  # Calculates the % difference between current & last values.
  @accessor 'difference', ->
    if @get('last')
      last = parseInt(@get('last'))
      current = parseInt(@get('current'))
      if last != 0
        diff = Math.abs(Math.round((current - last) / last * 100))
        "#{diff}%"
    else
      ""
  # Picks the direction of the arrow based on whether the current value is higher or lower than the last
  @accessor 'arrow', ->
    if @get('last')
      if parseInt(@get('current')) > parseInt(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'


  onClick: (event) ->
#    send_event('fan_state', { current: 'On' })
    @sendData()


  fanToggle: ->
    if (@get('fan_state') == '1')
      @set 'fan_state', '2'
#      send_event('fan_state', { current: "On" })
      
      return '2'
    else if (@get('fan_state') == '2')
      @set 'fan_state', '3'
#      send_event('fan_state', { current: "Auto" })
      return '3'
    else
      @set 'fan_state', '1'
#      send_event('fan_state', { current: "Off" })
      return '1'

  sendData: ->
    numPress = @get('id')

    if (numPress == 'temp_up')
      #send the password to openhab
      $.post '/openhab/tempChange',
        direction: 'increase'
    else if (numPress == 'temp_down')
      $.post '/openhab/tempChange',
        direction: 'decrease'
    else if (numPress == 'fan_state')
      newFanState = @fanToggle()
      $.post '/openhab/dispatch',
        deviceId: 'fan_state',
        command: newFanState
      $.post '/openhab/fanText',
        mode: newFanState
    else
      $.post '/music/button',
        button: numPress
