$(document).on "turbolinks:load", ->
  bag_vjet = [
    {
      weight: 0
      price_str: App.format_vnd(0)
      price: 0
    }
    {
      weight: 15
      price_str: App.format_vnd(143000)
      price: 143000
    }
    {
      weight: 20
      price_str: App.format_vnd(165000)
      price: 165000
    }
    {
      weight: 25
      price_str: App.format_vnd(220000)
      price: 220000
    }
    {
      weight: 30
      price_str: App.format_vnd(330000)
      price: 330000
    }
    {
      weight: 35
      price_str: App.format_vnd(385000)
      price: 385000
    }
    {
      weight: 40
      price_str: App.format_vnd(440000)
      price: 440000
    }
  ]
  bag_jet = [
    {
      weight: 0
      price_str: App.format_vnd(0)
      price: 0
    }
    {
      weight: 15
      price_str: App.format_vnd(150000)
      price: 150000
    }
    {
      weight: 20
      price_str: App.format_vnd(170000)
      price: 170000
    }
    {
      weight: 25
      price_str: App.format_vnd(230000)
      price: 230000
    }
    {
      weight: 30
      price_str: App.format_vnd(300000)
      price: 300000
    }
    {
      weight: 35
      price_str: App.format_vnd(350000)
      price: 350000
    }
    {
      weight: 40
      price_str: App.format_vnd(400000)
      price: 400000
    }
  ]
  bag_vna = [
    {
      weight: 20
      price_str: App.format_vnd(0)
      price: 0
    }
  ]
  titles_adult = [
    {
      value: 'male'
      name: 'MR'
    }
    {
      value: 'female'
      name: 'MS'
    }
  ]
  titles_child = [
    {
      value: 'male'
      name: 'MSTR'
    }
    {
      value: 'female'
      name: 'MISS'
    }
  ]

  App.PAX_ADULT = 'adult'
  App.PAX_CHILD = 'child'
  App.PAX_INFANT = 'infant'

  App.isRoundTrip = (category) ->
    return category == 'RT'

  App.baggages = (airline_category) ->
    switch
      when airline_category == 'vietnam_airlines' then bag_vna
      when airline_category == 'jetstar' then bag_jet
      when airline_category == 'vietjet_air' then bag_vjet
      else return []

  App.plane_category_name = (airline_category) ->
    switch
      when airline_category == 'vietnam_airlines' then 'Vietnam Airline'
      when airline_category == 'jetstar' then 'Jetstar'
      when airline_category == 'vietjet_air' then 'Vietjet Air'
      else return ''

  App.plane_img_name = (airline_category) ->
    switch
      when airline_category == 'vietnam_airlines' then 'vna.png'
      when airline_category == 'jetstar' then 'jet.png'
      when airline_category == 'vietjet_air' then 'vjet.png'
      else return ''

  App.is_vnairline = (airline_category) ->
    return airline_category == 'vietnam_airlines'

  App.is_vietjet = (airline_category) ->
    return airline_category == 'vietjet_air'

  App.is_jetstar = (airline_category) ->
    return airline_category == 'jetstar'

  App.titles = (category) ->
    switch
      when category == 'adult' then titles_adult
      when category == 'child' then titles_child
      when category == 'infant' then titles_child
      else return []
  App.paxCategoryName = (category) ->
    switch
      when category == 'adult' then 'Adult'
      when category == 'child' then 'Child'
      when category == 'infant' then 'Infant'
      else return ''