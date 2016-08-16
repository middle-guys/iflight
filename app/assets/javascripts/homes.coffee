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

  $(document).on 'click', '.searching-form-wrapper .dropdown-menu', (e) ->
    e.stopPropagation()
    return

  $('input[name*="_num"]').on 'change', ->
    total_pax = cal_total_passengers()
    txt_pax = ' Passenger'
    txt_pax = txt_pax + 's' if total_pax > 1
    $('#passengers-dropdown-btn').text(total_pax + txt_pax)

  cal_total_passengers = ->
    parseInt($('input[name="adult_num"]').val()) + parseInt($('input[name="child_num"]').val()) + parseInt($('input[name="infant_num"]').val())