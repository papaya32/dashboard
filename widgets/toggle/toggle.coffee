class Dashing.Toggle extends Dashing.ClickableWidget
  constructor: ->
    super
    @queryState()

  onData: (data) ->
    @queryState()

  @accessor 'state',
    get: -> @_state ? 'OFF'
    set: (key, value) -> @_state = value

  @accessor 'icon',
    get: -> if @['icon'] then @['icon'] else
      if @get('state') == 'ON' then @get('iconon') else @get('iconoff')
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconon',
    get: -> @['iconon'] ? 'fire'
    set: Batman.Property.defaultAccessor.set

  @accessor 'iconoff',
    get: -> @['iconoff'] ? 'asterisk'
    set: Batman.Property.defaultAccessor.set

  @accessor 'icon-style', ->
    if @get('state') == 'ON' then 'switch-icon-on' else 'switch-icon-off'

  toggleState: ->
    newState = if @get('state') == 'ON' then 'OFF' else 'ON'
    @set 'state', newState
    if (@get('state') == 'ON')
      $(@node).css('background-color', '#cc0000')
    else
      $(@node).css('background-color', '#0000cc')
    return newState

  queryState: ->
    $.get '/openhab/dispatch',
      widgetId: @get('id'),
      deviceId: @get('device'),
      deviceType: 'switch'
      (data) =>
        json = JSON.parse data
        @set 'state', json.state

  postState: ->
    if (@get('id') == 'heatac')
      newState = @toggleState()
      $.post '/openhab/dispatch',
        deviceId: @get('device'),
        command: newState
    else if (@get('id') == 'panic')
      $.post '/panic/press'

  ready: ->
    @queryState()
    if (@get('state') == 'ON')
      $(@node).css('background-color', '#cc0000')
    else
      $(@node).css('background-color', '#0000cc')

  onClick: (event) ->
    @postState()
