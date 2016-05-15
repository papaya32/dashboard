class Dashing.Textbutton extends Dashing.ClickableWidget
  constructor: ->
    super
#    @queryState()

  ready: ->
    # This is fired when the widget is done being rendered
#    @set 'state', 'Auto'
#    @queryState()
    $.post '/fan/press'

  onData: (data) ->
    # Fired when you receive data
    @queryState()

  # Any attribute that has the 'Dashing.AnimatedValue' will cause the number to animate when it changes. 
  @accessor 'current', Dashing.AnimatedValue
  @accessor 'currentIcon', Dashing.AnimatedValue

#  @accessor 'state',
#    get: -> @_state ? 'OFF'
#    set: (key, value) -> @_state = value

#  @accessor 'fan_state', ->
#    get: -> if @['fanTest'] then @['fanText'] else
#      if @get('state') == 'ON' then 'On' else 'Auto'
#    set: Batman.Property.defaultAccessor.set

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
    @sendData()


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
      $.post '/fan/press'
    else if (numPress== 'thermoPow')
      $.post '/thermo/pow'

#  queryState: ->
#    numPress = @get('id')

#    $.get '/openhab/dispatch',
#      widgetId: numPress
#      deviceId: @get('device')
#      deviceType: 'switch'
#      (data) =>
#        json = JSON.parse data
#        @set 'state', json.state
#    @fanToggle()
#    $.post 'print/something',
#      testNum: '2'
