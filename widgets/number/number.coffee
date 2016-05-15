class Dashing.Number extends Dashing.ClickableWidget
  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # Fired when you receive data
    # You could do something like have the widget flash each time data comes in by doing:
    # $(@node).fadeOut().fadeIn()

  # Any attribute that has the 'Dashing.AnimatedValue' will cause the number to animate when it changes. 
  @accessor 'current', Dashing.AnimatedValue

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
    @addToPass()
  addToPass: ->
    numPress = @get('id')

    if (numPress == 'send')
      #send the password to openhab
      $.post '/openhab/sendButton'
    else if (numPress == 'reset')
      $.post '/openhab/clearPass'
#    else if (numPress == 'arm')
#      $.post '/openhab/dispatch',
#        deviceId: 'securityState',
#        command: 'ON'
#    else if (numPress == 'disarm')
#      $.post '/openhab/dispatch',
#        deviceId: 'securityState',
#        command: 'OFF'
    else
      $.post '/openhab/addNum',
        deviceId: numPress
