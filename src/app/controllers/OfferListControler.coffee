# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OfferListCtrl", [
  "$scope"
  "$rootScope"
  "offerFactory"
  "offerList"
  "UtilsService"
  "Config"
  "promotedOffers"
  "projectsLimit"
  "id"
  ($scope, $rootScope, offerFactory, offerList, UtilsService, Config, promotedOffers, projectsLimit, id) ->
    $rootScope.smallBanner = false
    $rootScope.hideBanner = false

    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader

    $scope.searchPhrase = ''
    $scope.searchActive = false

    $scope.activeFilters = []
    $scope.offerList = offerList
    $scope.projectsLimit = projectsLimit.value
    $scope.promotedOffers = promotedOffers
    $scope.page = 1
    $scope.orderingOptions = [
      {name: 'Data zamknięcia rekrutacji - rosnąco', field: 'publish_to'},
      {name: 'Data zamknięcia rekrutacji - malejąco', field: '-publish_to'},
      {name: 'Najmniej popularne', field: 'volunteers_joined_count'},
      {name: 'Najbardziej popularne', field: '-volunteers_joined_count'}
    ]

    $scope.filteringOptions = [
      {name: 'Kultura', id: 1, class: 'culture'}
      {name: 'Sport', id: 2, class: 'sport'}
      {name: 'Edukacja', id: 3, class: 'education'}
      {name: 'Ekologia', id: 4, class: 'ecology'}
      {name: 'Prawa człowieka', id: 5, class: 'human-rights'}
      {name: 'Pomoc społeczna', id: 6, class: 'social-care'}
      {name: 'Zwierzęta', id: 7, class: 'animals'}
      {name: 'Przestrzeń miejska', id: 8, class: 'city'}
      {name: 'Inne', id: 9, class: 'other'}
    ]

    $scope.ordering = $scope.orderingOptions[0]

    $scope.clearSearch = ->
      $scope.searchPhrase = ''
      $scope.searchActive = false
      $scope.update()

    $scope.update = ->
      if $scope.searchPhrase.length
        promise = offerFactory.search({phrase: $scope.searchPhrase}).$promise
        $scope.searchActive = true
      else
        promise = offerFactory.getOffersWithCategories({categories: $scope.activeFilters.join(",")}).$promise

      promise.then(
        (data) ->
          $scope.offerList = data
          for offer, i in $scope.offerList
            if !offer.timeChartData?
              begin_date = new moment(offer.publish_from)
              end_date = new moment(offer.publish_to)
              now = new moment()

              diff_now = end_date - now
              diff_begin = end_date - begin_date

              if diff_now < 0
                diff_now = 0

              volunteers_accepted = offer.volunteers_joined_count
              volunteers_left = offer.volunteer_max_count - offer.volunteers_joined_count

              offer.timeChartData = [
                {
                  value: diff_now/diff_begin,
                  color: "#91004b"
                },
                {
                  value: 1 - (diff_now/diff_begin),
                  color: "#E2EAE9"
                }
              ]
              offer.volunteersChartData = [
                {
                  value: volunteers_accepted,
                  color: "#044c83"
                },
                {
                  value: volunteers_left,
                  color: "#E2EAE9"
                }
              ]
          return
      )
      return

    $scope.toogleFilter = (category_id) ->
      element_index = $scope.activeFilters.indexOf category_id
      console.log element_index
      if element_index isnt -1
        $scope.activeFilters.splice element_index, 1
      else
        $scope.activeFilters.push category_id
      return

    $scope.checkFilter = (category_id) ->
      $scope.activeFilters.indexOf(category_id) isnt -1

    if id?
      $scope.toogleFilter(id)

    $scope.$watch "activeFilters", (->
        $scope.update()
        return
      ), true

    $scope.$watch "currentPage",
      (newValue, oldValue) ->
        $scope.page = $scope.currentPage
        $scope.update()
        return

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.clearFilters = ->
      $scope.activeFilters = []
      return

    $scope.nextPage = ->
      $scope.currentPage = $scope.page
      return

    $scope.setPage = (pageId) ->
      $scope.currentPage = pageId
      return

    $scope.previousPage = ->
      $scope.currentPage = $scope.prevpage
      return

    $scope.chartOptions =
      percentageInnerCutout: 90
      showScale: false
      showTooltips: false

    return
])
