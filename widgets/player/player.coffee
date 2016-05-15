class Dashing.Player extends Dashing.ClickableWidget
  constructor: ->
    super

  ready: ->
    $.post '/music/refreshInfo'

  onData: (data) ->
      
  onClick: (event) ->
    $.post '/music/refreshInfo'
