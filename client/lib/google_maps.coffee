@gmaps =
  map: null
  currLocation: null
  drawingManager: null
  locationsHandler: false

  centerOnLocation: (location) ->
    loc = new google.maps.LatLng(location.lat, location.lon)
    @map.setCenter loc
    return

  initialize: (draw) ->
    mapOptions =
      zoom: 18
      minZoom: 12
      center: new google.maps.LatLng(40.044171, -76.313411)
      mapTypeId: google.maps.MapTypeId.ROADMAP

    map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)

    input = document.getElementById('pac-input')
    map.controls[google.maps.ControlPosition.TOP_LEFT].push input

    searchBox = new google.maps.places.SearchBox(input)
    google.maps.event.addListener searchBox, 'places_changed', ->
      places = searchBox.getPlaces()
      if places.length is 0
        toastr.warning 'Location could not be found!'
        return
      if places.length > 1
        toastr.warning 'More than one location was found.'
        return

      place = places[0]
      map.setCenter place.geometry.location
      return

    if draw
      @drawingManager = new google.maps.drawing.DrawingManager(
        drawingMode: google.maps.drawing.OverlayType.POLYGON
        drawingControl: true
        drawingControlOptions:
          position: google.maps.ControlPosition.BOTTOM_CENTER
          drawingModes: [
            google.maps.drawing.OverlayType.POLYGON
          ]
      )

      @drawingManager.setMap map

      google.maps.event.addListener @drawingManager, 'overlaycomplete', (e) ->
        path = e.overlay.getPath().getArray()
        return unless path

        #TODO: Prompt for confirmation of add

        e.overlay.setMap(null)

        Meteor.call 'addFence', path, (error, result) ->
          return toastr.error error.reason if error
          return toastr.success 'Fence added to data'

    Deps.autorun ->
      return if Session.get('located')
      p = Geolocation.currentLocation()
      if p is null
        return

      loc = new google.maps.LatLng(p.coords.latitude, p.coords.longitude)
      Session.get('located', true)
      map.setCenter loc

      return

    @map = map
    Session.set 'map', true
    return
