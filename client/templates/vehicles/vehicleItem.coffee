Template.vehicleItem.events
  'click .list-group-item': (e) ->
    e.preventDefault()

    Session.set 'selected', @_id
    gmaps.centerOnLocation @loc

  'click .btn-default': (e) ->
    e.preventDefault()

    Router.go '/history/' + @name

Template.vehicleItem.helpers
  active: ->
    id = Session.get 'selected'

    if id is @_id
      'active'
    else
      ''