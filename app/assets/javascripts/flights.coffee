$(document).on 'turbolinks:load', ->
  return unless $("#flights-result").length > 0

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

  received: (data) ->
    console.log(data)

  tmp =
  'itinerary':
    'category': 'RT'
    'ori_airport':
      'code': 'SGN'
      'name': 'Hồ Chí Minh'
      'name_unsigned': 'Ho Chi Minh'
      'short_name': 'HCM'
      'is_domestic': true
    'des_airport':
      'code': 'DAD'
      'name': 'Đà Nẵng'
      'name_unsigned': 'Da Nang'
      'short_name': 'DNang'
      'is_domestic': true
    'from_date': '25/11/2016'
    'to_date': '30/11/2016'
    'adult_num': 2
    'child_num': 0
    'infant_num': 0
  'depart_flights': [
    {
      'airline_type':'jetstar'
      'flight_code': 'BL564'
      'from_time': '9:20'
      'to_time': '10:40'
      'price_no_fee': 810000
      'price_adult': 1081000
      'price_child': 1041000
      'price_infant': 150000
      'price_total': 1081000
    }
    {
      'airline_type':'jetstar'
      'flight_code': 'BL560'
      'from_time': '17:30'
      'to_time': '18:50'
      'price_no_fee': 810000
      'price_adult': 1081000
      'price_child': 1041000
      'price_infant': 150000
      'price_total': 1081000
    }
    {
      'airline_type':'vietnam_airlines'
      'flight_code': 'VN 160'
      'from_time': '07:45'
      'to_time': '09:05'
      'price_no_fee': 1400000
      'price_adult': 1620000
      'price_child': 1195000
      'price_infant': 154000
      'price_total': 1620000
    }
    {
      'airline_type':'vietnam_airlines'
      'flight_code': 'VN 162'
      'from_time': '08:10'
      'to_time': '09:30'
      'price_no_fee': 2050000
      'price_adult': 2335000
      'price_child': 1731250
      'price_infant': 225500
      'price_total': 2335000
    }
    {
      'airline_type':'vietjet_air'
      'flight_code': 'VJ516'
      'from_time': '22:05'
      'to_time': '23:20'
      'price_no_fee': 580000
      'price_adult': 828000
      'price_child': 788000
      'price_infant': 0
      'price_total': 828000
    }
    {
      'airline_type':'vietjet_air'
      'flight_code': 'VJ528'
      'from_time': '22:50'
      'to_time': '00:05'
      'price_no_fee': 580000
      'price_adult': 828000
      'price_child': 788000
      'price_infant': 0
      'price_total': 828000
    }
  ]
  'return_flights': [
    {
      'airline_type':'jetstar'
      'flight_code': 'BL563'
      'from_time': '9:35'
      'to_time': '10:55'
      'price_no_fee': 420000
      'price_adult': 652000
      'price_child': 612000
      'price_infant': 150000
      'price_total': 652000
    }
    {
      'airline_type':'jetstar'
      'flight_code': 'BL565'
      'from_time': '15:25'
      'to_time': '16:45'
      'price_no_fee': 370000
      'price_adult': 597000
      'price_child': 557000
      'price_infant': 150000
      'price_total': 597000
    }
    {
      'airline_type':'vietnam_airlines'
      'flight_code': 'VN 7167'
      'from_time': '09:55'
      'to_time': '11:15'
      'price_no_fee': 2050000
      'price_adult': 2335000
      'price_child': 1731250
      'price_infant': 225500
      'price_total': 2335000
    }
    {
      'airline_type':'vietnam_airlines'
      'flight_code': 'VN 7179'
      'from_time': '10:20'
      'to_time': '11:40'
      'price_no_fee': 2050000
      'price_adult': 2335000
      'price_child': 1731250
      'price_infant': 225500
      'price_total': 2335000
    }
    {
      'airline_type':'vietjet_air'
      'flight_code': 'VJ515'
      'from_time': '21:35'
      'to_time': '22:50'
      'price_no_fee': 399000
      'price_adult': 628900
      'price_child': 588900
      'price_infant': 0
      'price_total': 628900
    }
    {
      'airline_type':'vietjet_air'
      'flight_code': 'VJ535'
      'from_time': '21:40'
      'to_time': '22:55'
      'price_no_fee': 399000
      'price_adult': 628900
      'price_child': 588900
      'price_infant': 0
      'price_total': 628900
    }
  ]

  itinerary = tmp.itinerary

  nav_lst_items = $('div.setup-panel .stepwizard-step a')
  wizard_contents = $('.setup-content')
  wizard_contents.hide()

  nav_lst_items.click (e) ->
    e.preventDefault()
    $target = $($(this).attr('href'))
    $item = $(this)
    if !$item.is('[disabled]')
      nav_lst_items.removeClass('btn-primary').addClass 'btn-default visited'
      $item.addClass 'btn-primary'
      wizard_contents.hide()
      $target.show()
    return

  $('div.setup-panel .stepwizard-step a.btn-primary').trigger 'click'

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

  loadDepartureFlights()

  loadReturnFlights()

  $('button.price').click (e) ->
    e.preventDefault()
    if $(this).data('type') == 'depart'
      itinerary.depart_flight = tmp.depart_flights[$(this).data('index')]
    else
      itinerary.return_flight = tmp.depart_flights[$(this).data('index')]

    curStep = $(this).closest ".setup-content"
    curStepBtn = curStep.attr "id"
    nextStepWizard = $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').parent().next().children('a')
    nextStepWizard.removeAttr('disabled').trigger('click')

  return