$(document).on 'turbolinks:load', ->
  return unless $("#flights-result").length > 0

  tmp = {}
  itinerary = {}
  shared_flight = {}

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
      time_depart: flight.time_depart
      time_arrive: flight.time_arrive
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
    $('#depature-flights').html('')
    $.each tmp.depart_flights, (i, flight) ->
      return generateFlightsRow('#depature-flights', i, 'depart', tmp.itinerary.ori_airport, tmp.itinerary.des_airport, flight)

  loadReturnFlights = ->
    $('#return-flights').html('')
    $.each tmp.return_flights, (i, flight) ->
      return generateFlightsRow('#return-flights', i, 'return', tmp.itinerary.des_airport, tmp.itinerary.ori_airport, flight)

  registerButtonPriceClick = ->
    $('a.price').click (e) ->
      e.preventDefault()
      if $(this).data('type') == 'depart'
        itinerary.depart_flight = tmp.depart_flights[$(this).data('index')]
        updateFlightSummary(itinerary.depart_flight, '#flight-depart')
        updateFlightHiddenFields(itinerary.depart_flight, 0)
        updatePriceTotalSummary(itinerary)
        updateBaggage(itinerary) if !App.isRoundTrip(itinerary.category)
      else
        itinerary.return_flight = tmp.return_flights[$(this).data('index')]
        updateFlightSummary(itinerary.return_flight, '#flight-return')
        updateFlightHiddenFields(itinerary.return_flight, 1)
        updatePriceTotalSummary(itinerary)
        updateBaggage(itinerary)

      curStep = $(this).closest ".setup-content"
      curStepBtn = curStep.attr "id"
      $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').addClass('visited')
      nextStepWizard = $('div.setup-panel .stepwizard-step a[href="#' + curStepBtn + '"]').parent().next().children('a')
      nextStepWizard.removeAttr('disabled').addClass('visited').trigger('click')
    
    $('a.share').click (e) ->
      e.preventDefault()
      if $(this).data('type') == 'depart'
        shared_flight = tmp.depart_flights[$(this).data('index')]
      else
        shared_flight = tmp.return_flights[$(this).data('index')]
      $('#sharing-flight-model').modal('show')

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
  updateFlightHiddenFields = (flight, index) ->
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
        select.append($('<option></option>').attr('value', value.weight).attr('price', value.price).text(value.weight + ' kg (' + value.price_str + ')' ))

  # update summary tab
  updatePriceTotalSummary = (itinerary) ->
    tmp_price_total = itinerary.depart_flight.price_total
    if itinerary.return_flight != undefined
      tmp_price_total = tmp_price_total + itinerary.return_flight.price_total

    $('select[name*="lug_weight"] option:selected').each (index, val) ->
      tmp_price_total = tmp_price_total + parseInt($(this).attr('price'))

    $('.pax-block .price-total').html(App.format_vnd(tmp_price_total))

  updateFlightSummary = (flight, id_container) ->
    flight.plane_category_name = App.plane_category_name(flight.airline_type)
    flight.is_jetstar = App.is_jetstar(flight.airline_type)
    flight.is_vietjet = App.is_vietjet(flight.airline_type)
    flight.is_vnairline = App.is_vnairline(flight.airline_type)
    flight.price_total_str = App.format_vnd(flight.price_total)
    template = $('#summary-flight-template').html()
    return $(id_container).html(Mustache.render(template, flight))

  updateContactSummary = ->
    $('.contact-block span.title').html($('select#order_contact_gender option:selected').text())
    $('.contact-block span.name').html($('input[name="order[contact_name]"]').val())
    $('.contact-block span.phone').html($('input[name="order[contact_phone]"]').val())
    $('.contact-block span.email').html($('input[name="order[contact_email]"]').val())

  registerContactEvents = ->
    $("[data-behavior~=update-summary]").focusout ->
      updateContactSummary()
    $('select#order_contact_gender').change ->
      updateContactSummary()

  registerContactEvents()

  registerSelectBaggageEvents = ->
    $('select[name*="lug_weight"]').change ->
      updatePriceTotalSummary(itinerary)

  registerSelectBaggageEvents()

  updateFlightsResult = (flights, is_depart, criteria) ->
    switch
      when criteria == 'price-asc'
        flights.sort(App.sort_by('price_adult', false, parseInt))
      when criteria == 'price-desc'
        flights.sort(App.sort_by('price_adult', true, parseInt))
      when criteria == 'time-asc'
        flights.sort(App.sort_by('time_depart', false, parseInt))
      when criteria == 'time-desc'
        flights.sort(App.sort_by('time_depart', true, parseInt))

    if (is_depart)
      loadDepartureFlights()
    else
      loadReturnFlights()

    registerButtonPriceClick()

  registerSelectSortEvents = ->
    $('select#sort-depart').change ->
      updateFlightsResult(tmp.depart_flights, true, $(this).find(':selected').val())

    $('select#sort-return').change ->
      updateFlightsResult(tmp.return_flights, false, $(this).find(':selected').val())

  registerSelectSortEvents()

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
          # minlength: 10
          # maxlength: 11
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

  # sharing flight model
  $('#sharing-btn').click (e) ->
    e.preventDefault()
    sender_name = $('input#sender-name').val()
    receiver_email = $('input#receiver-email').val()
    $.ajax
      type: 'GET'
      contentType: 'application/json; charset=utf-8'
      url: '/flights/share'
      data: {"sender_name": sender_name, "receiver_email": receiver_email, flight: shared_flight}
      success: (result) ->
        console.info('share request success')
        clearSharingForm();
        return
      error: (e) ->
        console.error('share request error')
        clearSharingForm();
        return

  clearSharingForm = ->
    $('#sharing-flight-model').modal('hide')
    $('input#sender-name').val('')
    $('input#receiver-email').val('')

  return