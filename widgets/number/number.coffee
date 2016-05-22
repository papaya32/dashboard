class Dashing.Number extends Dashing.ClickableWidget
  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # Fired when you receive data
    # You could do something like have the widget flash each time data comes in by doing:
    console.log data
#    jsonData = JSON.parse(data)
    if (data.background == "green")
      #green background
      $(@node).css('background-color', '#00b300')
    else if (data.background == "grey")
      #grey background
      $(@node).css('background-color', '#333333')
    else if (data.background == "red")
      #red background
      $(@node).css('background-color', '#cc0000')

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
    else if (numPress.charAt(0) == 'c')
      $.post '/expense/button',
        deviceId: numPress
    else
      $.post '/openhab/addNum',
        deviceId: numPress
