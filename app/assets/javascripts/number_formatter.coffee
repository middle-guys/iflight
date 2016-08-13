$(document).on "turbolinks:load", ->
  App.add_commas = (nStr) ->
    nStr += ''
    x = nStr.split('.')
    x1 = x[0]
    x2 = if x.length > 1 then '.' + x[1] else ''
    rgx = /(\d+)(\d{3})/
    while rgx.test(x1)
      x1 = x1.replace(rgx, '$1' + ',' + '$2')
    x1 + x2

  App.format_vnd = (number) ->
    App.add_commas(number) + ' VND'