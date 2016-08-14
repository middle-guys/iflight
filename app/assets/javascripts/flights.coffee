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
    tmp.return_flights.sort(App.sort_by('price_adult', false, parseInt)) if App.isRoundTrip(itinerary.category)
    loadDepartureFlights()
    loadReturnFlights() if App.isRoundTrip(itinerary.category)
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
    flight_details =
      from_time: flight.from_time
      to_time: flight.to_time
      ori_code: depart_airport.code
      des_code: arrive_airport.code
      price: App.format_vnd(flight.price_adult)
      index: index
      round_type: round_type
      is_jetstar: App.is_jetstar(flight.airline_type)
      is_vietjet: App.is_vietjet(flight.airline_type)
      is_vnairline: App.is_vnairline(flight.airline_type)

    template = $('#flight-details-template').html()
    return $(id_container).append(Mustache.render(template, flight_details))

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
        generatePassengersInfo(itinerary) if !App.isRoundTrip(itinerary.category)
      else
        itinerary.return_flight = tmp.depart_flights[$(this).data('index')]
        generatePassengersInfo(itinerary)

      curStep = $(this).closest ".setup-content"
      curStepBtn = curStep.attr "id"
      $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').addClass('visited')
      nextStepWizard = $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').parent().next().children('a')
      nextStepWizard.removeAttr('disabled').addClass('visited').trigger('click')

  $('a.back').click (e) ->
    e.preventDefault()
    curStep = $(this).closest ".setup-content"
    curStepBtn = curStep.attr "id"
    prevStepWizard = $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').parent().prev().children('a')
    prevStepWizard.trigger('click')
  $('a.next').click (e) ->
    e.preventDefault()
    if $('form#passenger-info').valid()
      curStep = $(this).closest ".setup-content"
      curStepBtn = curStep.attr "id"
      nextStepWizard = $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').parent().next().children('a')
      nextStepWizard.removeAttr('disabled').addClass('visited').trigger('click')

  # generate passenger information
  addPassengerInfo = (index, category, itinerary) ->
    name_input = App.paxCategoryName(category) + index
    date_name_input = 'date' + App.paxCategoryName(category) + index
    pax_data = 
      no: index
      category: App.paxCategoryName(category)
      titles: App.titles(category)
      bag_depart_options: App.baggages(itinerary.depart_flight.airline_type)
      round_trip: App.isRoundTrip(itinerary.category)
      is_infant: false
      name_input: name_input
      date_name_input: date_name_input
    pax_data.bag_return_options = App.baggages(itinerary.return_flight.airline_type) if App.isRoundTrip(itinerary.category)
    pax_data.is_infant = category == App.PAX_INFANT ? true : false

    template = $('#passenger-template').html()
    $('#passenger-info-container').append(Mustache.render(template, pax_data))

    # validate input name
    $('input[name="'+name_input+'"]').rules 'add',
      required: true
      wordCount: ['2']

    # validate input date of DoB infant
    if category == App.PAX_INFANT
      $('input[name="'+date_name_input+'"]').rules 'add',
      required: true
      vietnameseDate: true

  generatePassengersInfo = (itinerary) ->
    $('#passenger-info-container').html('')

    index = 1
    i = 1
    while i <= itinerary.adult_num
      addPassengerInfo(index, App.PAX_ADULT, itinerary)
      i++
      index++

    i = 1
    while i <= itinerary.child_num
      addPassengerInfo(index, App.PAX_CHILD, itinerary)
      i++
      index++

    i = 1
    while i <= itinerary.infant_num
      addPassengerInfo(index, App.PAX_INFANT, itinerary)
      i++
      index++

  # validate passenger form
  $('form#passenger-info').validate
    rules:
      contact_name:
        required: true
        wordCount: ['2']
      contact_phone:
        required: true
        number: true
        minlength: 10
        maxlength: 11
      contact_email:
        required: true
        email: true
    highlight: (element) ->
      $(element).closest('.form-group').addClass 'has-danger'
      return
    unhighlight: (element) ->
      $(element).closest('.form-group').removeClass 'has-danger'
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