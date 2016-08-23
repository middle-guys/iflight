$(document).on "turbolinks:load", ->
  App.random_number_in_range = (minNumber, maxNumber) ->
    Math.floor(Math.random() * maxNumber) + minNumber  