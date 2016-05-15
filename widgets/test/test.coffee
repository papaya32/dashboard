class Dashing.Test extends Dashing.ClickableWidget

  constructor: ->
    super
    $.post 'mqtt/subscribe',
      topic: @get('subscribe'),
      widgetId: @get('id'),
      (data) =>
        console.log data

  ready: ->

  onData: (data) ->

  onClick: (node, event) ->
    $.post '/mqtt/publish',
      topic: @get('publish'),
      message: 'message',
      (data) =>
        alert(data)
