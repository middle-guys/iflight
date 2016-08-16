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
        updateFlight(itinerary.depart_flight, 0)
        updateBaggage(itinerary) if !App.isRoundTrip(itinerary.category)
      else
        itinerary.return_flight = tmp.return_flights[$(this).data('index')]
        updateFlight(itinerary.return_flight, 1)
        updateBaggage(itinerary)

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
    if $('form#new_order').valid()
      curStep = $(this).closest ".setup-content"
      curStepBtn = curStep.attr "id"
      nextStepWizard = $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').parent().next().children('a')
      nextStepWizard.removeAttr('disabled').addClass('visited').trigger('click')

  # generate passenger information
  updateFlight = (flight, index) ->
    $('input[name="order[flights_attributes]['+index+'][plane_category_id]"]').val(flight.plane_category_id)
    $('input[name="order[flights_attributes]['+index+'][airline_type]"]').val(flight.airline_type)
    $('input[name="order[flights_attributes]['+index+'][code_flight]"]').val(flight.code_flight)
    $('input[name="order[flights_attributes]['+index+'][time_depart]"]').val(flight.time_depart)
    $('input[name="order[flights_attributes]['+index+'][time_arrive]"]').val(flight.time_arrive)
    $('input[name="order[flights_attributes]['+index+'][price_web]"]').val(flight.price_web)
    $('input[name="order[flights_attributes]['+index+'][price_total]"]').val(flight.price_total)

  updateBaggage = (itinerary) ->
    updateOptionsBaggage(itinerary, 'select[name*="depart_lug_weight"]', itinerary.depart_flight.airline_type)
    updateOptionsBaggage(itinerary, 'select[name*="return_lug_weight"]', itinerary.return_flight.airline_type) if App.isRoundTrip(itinerary.category)

  updateOptionsBaggage = (itinerary, select_selector, airline_type) ->
    $(select_selector).each (index, val) ->
      bag_options = App.baggages(airline_type)
      select = $(this)
      select.html('')
      $.each bag_options, (key, value) ->
        select.append($('<option></option>').attr('value', value.weight).text(value.weight + ' kg (' + value.price + ')' ))

  # validate passenger form
  applyFormValidation = ->
    $('form#new_order').validate
      rules:
        "order[contact_name]":
          required: true
          wordCount: ['2']
        "order[contact_phone]":
          required: true
          number: true
          minlength: 10
          maxlength: 11
        "order[contact_email]":
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
    $('input[name*="name"]').each (index, val) ->
      $(this).rules 'add',
        required: true
        wordCount: ['2']

    $('input[name*="dob"]').each (index, val) ->
      $(this).rules 'add',
        required: true
        vietnameseDate: true

  applyFormValidation()

  return