class Dashing.numpad extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    h = today.getHours()
    m = today.getMinutes()
    m = @formatTime(m)

    options = { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric' };
    #options.timeZoneName = 'short';

    @set('tester1', "1")
    @set('tester2', "2")
    @set('tester3', "3")
    @set('tester4', "4)
    @set('tester5', "5")
    @set('tester6', "6")
    @set('tester7', "7")
    @set('tester8', "8")
    @set('tester9', "9")
    @set('tester0', "0")

  formatTime: (i) ->
    if i < 10 then "0" + i else i

  formatAmPm: (h) ->
    if h >= 12 then "PM" else "AM"

  formatHours: (h) ->
    if h > 12
      h - 12
    else if h == 0
      12
    else
      h
