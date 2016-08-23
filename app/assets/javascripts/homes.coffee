$(document).on 'turbolinks:load', ->
  return unless $(".searching-form-wrapper").length > 0
  routes = {}
  ori_id = '1'

  $('#ori_airport_id').change( ->
    $("#ori_airport_id option[value='']").remove() if $("#ori_airport_id option[value='']").length > 0
    $('button[type="submit"]').prop('disabled', false)
    ori_id = $('#ori_airport_id option:selected').val()
    updateDestinationAirport()
  )

  getRoutes = ->
    $.ajax
      type: 'GET'
      contentType: 'application/json; charset=utf-8'
      url: 'routes/destination'
      data: ''
      dataType: 'json'
      success: (result) ->
        routes = result
        return
      error: ->
        console.error('error get destination')
        return {}

  getRoutes()

  updateDestinationAirport = ->
    $('#des_airport_id').empty()
    for route in routes
      if route.ori_airport_id == parseInt(ori_id)
        $('#des_airport_id').append $('<option>',
          value: route.des_airport_id,
          text: route.des_airport.name_unsigned + ' (' + route.des_airport.code + ')' )
    return

  $('#date-itinerary .input-daterange').datepicker
    setDate: new Date()
    format: 'dd/mm/yyyy'
    autoclose: true
    todayHighlight: true
    startDate: '0d'
    orientation: 'bottom left'

  $('#date-itinerary .input-daterange').data('datepicker').pickers[0].setDate(new Date());

  $('.lbl_itinerary_type').click (e) ->
    if e.currentTarget.htmlFor == 'itinerary_type_round_trip'
      $('#date_return').prop 'disabled', false
    else
      $('#date_return').prop 'disabled', true
    return

  $('input[name="adult_num"]').TouchSpin
    initval: 1
    min: 1
    max: 6
    step: 1
  $('input[name="child_num"]').TouchSpin
    initval: 0
    min: 0
    max: 6
    step: 1
  $('input[name="infant_num"]').TouchSpin
    initval: 0
    min: 0
    max: 6
    step: 1

  generateRecentlySearchingRow = (id_container, search) ->
    recently_searching =
      depart_id: search.depart_id
      return_id: search.return_id
      depart_flight: search.depart
      return_flight: search.return
      depart_date: search.depart_date
      return_date: search.return_date
      is_round_trip: App.isRoundTrip(search.itinerary_type)
      is_one_way: !App.isRoundTrip(search.itinerary_type)
      itinerary_type: search.itinerary_type
      adult_num: search.adult_num
      child_num: search.child_num
      infant_num: search.infant_num
      search_time: (new Date(search.search_time)).toLocaleString()
      img_random_number: App.random_number_in_range(1, 10)

    template = $('#recently-searching-template').html()
    return $(id_container).append(Mustache.render(template, recently_searching))

  if localStorage.history != undefined
    history = JSON.parse(localStorage.history)
    if history.length > 0
      $("#recent-search-container").show()
      for search in history.reverse()
        generateRecentlySearchingRow("#recently-searching", search)
    else
      $("#recent-search-container").hide()
  else
    $("#recent-search-container").hide()

  $(document).on 'click', '.searching-form-wrapper .dropdown-menu', (e) ->
    e.stopPropagation()
    return

  $('form').on 'submit', ->
    history = []
    if localStorage.history
      history = JSON.parse(localStorage.history)

    history.push({
      depart_id: $('#ori_airport_id option:selected').val(),
      return_id: $('#des_airport_id option:selected').val(),
      depart: $('#ori_airport_id option:selected').text(),
      return: $('#des_airport_id option:selected').text(),
      itinerary_type: $('input[name=itinerary_type]:checked').val(),
      depart_date: $('#date_depart').val(),
      return_date: $('#date_return').val(),
      adult_num: $("#adult_num").val(),
      child_num: $("#child_num").val(),
      infant_num: $("#infant_num").val()
      search_time: new Date()
    });

    if history.length > 6
      history.shift()

    localStorage.history = JSON.stringify(history)
    return true

  $('input[name*="_num"]').on 'change', ->
    total_pax = cal_total_passengers()
    txt_pax = ' Passenger'
    txt_pax = txt_pax + 's' if total_pax > 1
    $('#passengers-dropdown-btn').text(total_pax + txt_pax)

  cal_total_passengers = ->
    parseInt($('input[name="adult_num"]').val()) + parseInt($('input[name="child_num"]').val()) + parseInt($('input[name="infant_num"]').val())