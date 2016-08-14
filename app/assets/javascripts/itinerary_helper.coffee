$(document).on "turbolinks:load", ->
  bag_vjet = [
    {
      weight: 0
      price: App.format_vnd(0)
    }
    {
      weight: 15
      price: App.format_vnd(143000)
    }
    {
      weight: 20
      price: App.format_vnd(165000)
    }
    {
      weight: 25
      price: App.format_vnd(220000)
    }
    {
      weight: 30
      price: App.format_vnd(330000)
    }
    {
      weight: 35
      price: App.format_vnd(385000)
    }
    {
      weight: 40
      price: App.format_vnd(440000)
    }
  ]
  bag_jet = [
    {
      weight: 0
      price: App.format_vnd(0)
    }
    {
      weight: 15
      price: App.format_vnd(150000)
    }
    {
      weight: 20
      price: App.format_vnd(170000)
    }
    {
      weight: 25
      price: App.format_vnd(230000)
    }
    {
      weight: 30
      price: App.format_vnd(300000)
    }
    {
      weight: 35
      price: App.format_vnd(350000)
    }
    {
      weight: 40
      price: App.format_vnd(400000)
    }
  ]
  bag_vna = [
    {
      weight: 20
      price: App.format_vnd(0)
    }
  ]
  titles_adult = [
    {
      value: 1
      name: 'MR'
    }
    {
      value: 2
      name: 'MS'
    }
  ]
  titles_child = [
    {
      value: 1
      name: 'MSTR'
    }
    {
      value: 2
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