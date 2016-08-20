$(document).on "turbolinks:load", ->
  getWordCount = (string) ->
    words = string.split(' ')
    words = words.filter((words) ->
      words.length > 0
    ).length
    words

  $.validator.addMethod 'wordCount', ((value, element, params) ->
    count= getWordCount(value)
    if count >= params[0]
      return true
    return
  ), $.validator.format('A minimum of {0} words is required here.')

  $.validator.addMethod 'vietnameseDate', ((value, element) ->
    return value.match /^\d\d?\/\d\d?\/\d\d\d\d$/
  ), $.validator.format('Please enter a date in the format DD/MM/YYYY. E.g: 15/09/1991')