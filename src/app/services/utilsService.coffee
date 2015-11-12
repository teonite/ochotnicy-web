# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").factory "UtilsService", [
  "$resource"
  "Config"
  ($resource, Config) ->
    filter_with_specification = (specification, array) ->
      result = []
      array.forEach (element) ->
        for prop of specification
          return  if specification[prop] isnt element[prop]
        result.push element
        return

      result
    buildUrl: (base, options) ->
      # uses base string to construct url with params in options dict
      options = options or {}
      options.pagination = options.pagination or {}
      page = options.pagination.page or null
      limit = options.pagination.limit or null
      url = base + (if base[base.length - 1] is "/" then "?" else "/?")
      for optInd of options
        unless optInd is "pagination"
          opt = options[optInd]
          url += "&" + optInd + "=" + opt
      url += if page then '&page=' + page else ''
      url += if limit then '&limit=' + limit else ''
      url

    rangeObjects: (n, obj) ->
      periods = []
      if typeof obj is "object"
        i = 0

        while i < n
          periods.push obj
          i++
      periods

    range: (n) ->
      periods = []
      i = 0

      while i < n
        periods.push i
        i++
      periods

    zip: (arrays) ->
      arrays[0].map (_, i) ->
        arrays.map (array) ->
          array[i]

    filter: filter_with_specification
    getFirst: (specification, array) ->
      filter_with_specification(specification, array)[0]

    isEmpty: (obj) ->
      for i of obj
        continue
      true

    getMediaUrl: (mediaUrl, type) ->
      if mediaUrl?
        Config.staticRoot + mediaUrl
      else
        switch type
          when "photo"
            "/img/image-placeholder.png"
          when "user"
            "/img/user-placeholder.png"
          else
            ""

    isValidDate: (dateStr) ->
      if dateStr == undefined
        return false
      dateTime = Date.parse(dateStr)
      if isNaN(dateTime)
        return false
      true

    getDateDifference: (fromDate, toDate) ->
      Date.parse(toDate) - Date.parse(fromDate)

    isValidDateRange: (fromDate, toDate) ->
      if fromDate == '' or toDate == ''
        return true
      if this.isValidDate(fromDate) == false
        return false
      if this.isValidDate(toDate) == true
        days = this.getDateDifference(fromDate, toDate)
        if days <= 0
          return false
      true

    setDirtyFields: (form) ->
      angular.forEach form.$error, (error) ->
        angular.forEach error, (field) ->
          field.$setDirty()
      return
]