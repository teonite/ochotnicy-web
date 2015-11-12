# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
#taken from: https://gist.github.com/benmj/6380466

angular.module("wolontariat.services").factory 'geocoderFactory', [
  "$localStorage", "$q", "$timeout", "uiGmapGoogleMapApi"
  ($localStorage, $q, $timeout, uiGmapGoogleMapApi) ->
    locations = if $localStorage.locations then JSON.parse($localStorage.locations) else {}
    queue = []
    # Amount of time (in milliseconds) to pause between each trip to the
    # Geocoding API, which places limits on frequency.
    queryPause = 250

    #
    # executeNext() - execute the next function in the queue.
    #                  If a result is returned, fulfill the promise.
    #                  If we get an error, reject the promise (with message).
    #                  If we receive OVER_QUERY_LIMIT, increase interval and try again.
    #

    executeNext = ->
      task = queue[0]
      uiGmapGoogleMapApi.then (maps) ->
        geocoder = new (maps.Geocoder)
        geocoder.geocode { address: task.address }, (result, status) ->
          if status == maps.GeocoderStatus.OK
            latLng =
              latitude: result[0].geometry.location.lat()
              longitude: result[0].geometry.location.lng()
            queue.shift()
            locations[task.address] = latLng
            $localStorage.locations = JSON.stringify(locations)
            task.d.resolve latLng
            if queue.length
              $timeout executeNext, queryPause
          else if status == maps.GeocoderStatus.ZERO_RESULTS
            queue.shift()
            task.d.reject
              type: 'zero'
              message: 'Zero results for geocoding address ' + task.address
          else if status == maps.GeocoderStatus.OVER_QUERY_LIMIT
            queryPause += 250
            $timeout executeNext, queryPause
          else if status == maps.GeocoderStatus.REQUEST_DENIED
            queue.shift()
            task.d.reject
              type: 'denied'
              message: 'Request denied for geocoding address ' + task.address
          else if status == maps.GeocoderStatus.INVALID_REQUEST
            queue.shift()
            task.d.reject
              type: 'invalid'
              message: 'Invalid request for geocoding address ' + task.address
          return
        return
      return

    { latLngForAddress: (address) ->
      d = $q.defer()
      if _.has(locations, address)
        $timeout ->
          d.resolve locations[address]
          return
      else
        queue.push
          address: address
          d: d
        if queue.length == 1
          executeNext()
      d.promise
   }
]
