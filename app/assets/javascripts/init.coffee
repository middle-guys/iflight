window.App ||= {}

App.init = ->
  $("a, span, i, div").tooltip()
  $('[data-toggle="tooltip"]').tooltip()
  $('.dropdown').hover (->
    $('.dropdown-menu', this).stop(true, true).fadeIn 'fast'
    $(this).toggleClass 'open'
    $('b', this).toggleClass 'caret caret-up'
    return
  ), ->
    $('.dropdown-menu', this).stop(true, true).fadeOut 'fast'
    $(this).toggleClass 'open'
    $('b', this).toggleClass 'caret caret-up'
    return

$(document).on "turbolinks:load", ->
  App.init()
