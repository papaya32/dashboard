class Dashing.Cameras extends Dashing.ClickableWidget

  onClick: (event) ->
    $.post '/cameras/press'
