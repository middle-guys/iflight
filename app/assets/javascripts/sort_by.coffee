$(document).on "turbolinks:load", ->
  App.sort_by = (field, reverse, primer) ->
    key = if primer then ((x) ->
      primer x[field]
    ) else ((x) ->
      x[field]
    )

    reverse = if !reverse then 1 else -1

    (a, b) ->
      a = key(a)
      b = key(b)
      reverse * ((a > b) - (b > a))