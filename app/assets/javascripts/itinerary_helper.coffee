$(document).on "turbolinks:load", ->
  App.is_round_trip = (category) ->
    return category == 'RT'