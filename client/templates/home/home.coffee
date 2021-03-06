liveMarkers = null

Template.home.rendered = ->
  gmaps.initialize(false) unless Session.get('map')

  Deps.autorun ->
    loc = Geolocation.latLng()
    vehicle = Vehicles.findOne(user: Meteor.user()._id)

    return if not loc? or not vehicle?

    return if vehicle.loc.lat is loc.lat and vehicle.loc.lon is loc.lng

    location =
      lat: loc.lat
      lon: loc.lng

    Meteor.call 'updateVehicleLocation', location, (error, result) ->
      return toastr.error error.reason if error
      if result?
        toastr.success 'Vehicle ' + result.name + ' updated' if result?
        Session.set 'lastUpdate', moment()

    Meteor.call 'addVehicleHistory', vehicle, (error, result) ->
      return toastr.error error.reason if error
      if result?
        toastr.success 'Vehicle ' + result.name + ' history added'

    return

  @liveMarkers = LiveMaps.addMarkersToMap(gmaps.map, [
      cursor: Vehicles.find()
      onClick: ->
        Session.set 'selected', @id
      transform: (vehicle) ->
        title: vehicle.name
        position: new google.maps.LatLng(vehicle.loc.lat, vehicle.loc.lon)
        animation: null
        icon: '//maps.google.com/mapfiles/ms/icons/blue-dot.png'
  ])

  return

Template.home.destroyed = ->
  Session.set 'selected', null
  Session.set 'map', false
  return
