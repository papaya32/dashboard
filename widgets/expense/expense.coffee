class Dashing.Expense extends Dashing.ClickableWidget
  constructor: ->
    super

  ready: ->
    $.post '/expense/start'
  onData: (data) ->
    debugger      
  onClick: (event) ->
