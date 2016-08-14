$(document).on 'turbolinks:load', ->
  return unless $("#flights-result").length > 0

  tmp = {}
  itinerary = {}

  # loading data from server
  App.flights = App.cable.subscriptions.create {
    channel: "FlightsChannel"
    uuid: $("#uuid").val()
  },
  connected: ->
    console.log('connected')

  disconnected: ->
    console.log('disconnected')

  received: (result) ->
    tmp = result.data
    itinerary = tmp.itinerary
    tmp.depart_flights.sort(App.sort_by('price_adult', false, parseInt))
    tmp.return_flights.sort(App.sort_by('price_adult', false, parseInt)) if App.is_round_trip(itinerary.category)
    loadDepartureFlights()
    loadReturnFlights() if App.is_round_trip(itinerary.category)
    registerButtonPriceClick()

  # setup wizard
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

  # generate flights row
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
      html: $('<a/>',
        class: 'btn btn-primary price'
        href: '#'
        'data-index': index
        'data-type': round_type
        text: App.format_vnd(flight.price_adult)))

    return $wrapper.append($image).append($info).append($button).appendTo(id_container)

  loadDepartureFlights = ->
    $.each tmp.depart_flights, (i, flight) ->
      return generateFlightsRow('#depature-flights', i, 'depart', tmp.itinerary.ori_airport, tmp.itinerary.des_airport, flight)

  loadReturnFlights = ->
    $.each tmp.return_flights, (i, flight) ->
      return generateFlightsRow('#return-flights', i, 'return', tmp.itinerary.des_airport, tmp.itinerary.ori_airport, flight)

  registerButtonPriceClick = ->
    $('a.price').click (e) ->
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

  # generate passenger information
  

  # validate passenger form
  $('form').validate
    rules:
      contactname:
        required: true
        minlength: 5
      contactphone:
        required: true
        number: true
        minlength: 10
        maxlength: 11
      contactemail:
        required: true
        email: true
    highlight: (element) ->
      $(element).closest('.form-group').addClass 'has-danger'
      return
    unhighlight: (element) ->
      $(element).closest('.form-group').removeClass 'has-danger'
      return
    success: (element) ->
      $(element).closest('.form-group').addClass 'has-success'
      return

    errorElement: 'div'
    errorClass: 'form-control-feedback'
    errorPlacement: (error, element) ->
      if element.parent('.input-group').length
        error.insertAfter element.parent()
      else
        error.insertAfter element
      return

  return