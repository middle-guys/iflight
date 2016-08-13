$(document).on 'turbolinks:load', ->
  return unless $("#flights-result").length > 0

  tmp = {}
  itinerary = {}

  App.flights = App.cable.subscriptions.create {
    channel: "FlightsChannel"
    uuid: $("#uuid").val()
  },
  connected: ->
    console.log('connected')
    # Called when the subscription is ready for use on the server

  disconnected: ->
    console.log('disconnected')
    # Called when the subscription has been terminated by the server

  received: (result) ->
    tmp = result.data
    itinerary = tmp.itinerary
    loadDepartureFlights()
    loadReturnFlights() if itinerary.category == 'RT'
    registerButtonPriceClick()

  nav_lst_items = $('div.setup-panel .stepwizard-step a')
  wizard_contents = $('.setup-content')
  wizard_contents.hide()

  nav_lst_items.click (e) ->
    e.preventDefault()
    $target = $($(this).attr('href'))
    $item = $(this)
    if !$item.is('[disabled]')
      nav_lst_items.removeClass('current').addClass 'btn-secondary'
      $item.addClass 'current'
      wizard_contents.hide()
      $target.show()
    return
  
  $('div.setup-panel .stepwizard-step a.current').trigger 'click'

  generateFlightsRow = (id_container, index, round_type, depart_airport, arrive_airport, flight) ->
    $wrapper = $('<div/>', class: 'row flight-result')

    $image_vje = $('<div/>',
      class: 'col-xs-3'
      html: $('<img/>',
        src: 'http://' + window.location.host + '/assets/airlines/vjet.png'
        alt: 'Vietjet Air'))

    $image_vna = $('<div/>',
      class: 'col-xs-3'
      html: $('<img/>',
        src: 'http://' + window.location.host + '/assets/airlines/vna.png'
        alt: 'Vietnam Airline'))

    $image_jet = $('<div/>',
      class: 'col-xs-3'
      html: $('<img/>',
        src: 'http://' + window.location.host + '/assets/airlines/jet.png'
        alt: 'Jetstar'))

    $image = switch
      when flight.airline_type == 'vietnam_airlines' then $image_vna
      when flight.airline_type == 'jetstar' then $image_jet
      when flight.airline_type == 'vietjet_air' then $image_vje
      else $image_vje

    $info = $('<div/>', class: 'col-xs-6')

    $depart = $('<div/>', class: 'depart').append($('<span/>',
      class: 'time'
      text: flight.from_time)).append($('<span/>',
      class: 'stop-station'
      text: depart_airport.code))

    $arrow = $('<div/>',
      class: 'arrow-right',
      html: '<i class="fa fa-long-arrow-right" aria-hidden="true"></i>')

    $arrive = $('<div/>', class: 'arrive').append($('<span/>',
      class: 'time'
      text: flight.to_time)).append($('<span/>',
      class: 'stop-station'
      text: arrive_airport.code))

    $info.append($depart).append($arrow).append($arrive)

    $button = $('<div/>',
      class: 'col-xs-3'
      html: $('<button/>',
        class: 'btn btn-primary price'
        type: 'button'
        'data-index': index
        'data-type': round_type
        text: flight.price_adult))

    return $wrapper.append($image).append($info).append($button).appendTo(id_container)

  loadDepartureFlights = ->
    $.each tmp.depart_flights, (i, flight) ->
      return generateFlightsRow('#depature-flights', i, 'depart', tmp.itinerary.ori_airport, tmp.itinerary.des_airport, flight)

  loadReturnFlights = ->
    $.each tmp.return_flights, (i, flight) ->
      return generateFlightsRow('#return-flights', i, 'return', tmp.itinerary.des_airport, tmp.itinerary.ori_airport, flight)

  registerButtonPriceClick = ->
    $('button.price').click (e) ->
      e.preventDefault()
      if $(this).data('type') == 'depart'
        itinerary.depart_flight = tmp.depart_flights[$(this).data('index')]
      else
        itinerary.return_flight = tmp.depart_flights[$(this).data('index')]

      curStep = $(this).closest ".setup-content"
      curStepBtn = curStep.attr "id"
      $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').addClass('visited')
      nextStepWizard = $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').parent().next().children('a')
      nextStepWizard.removeAttr('disabled').trigger('click')

  return