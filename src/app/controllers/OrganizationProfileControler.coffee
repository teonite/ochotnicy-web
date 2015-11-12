# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OrganizationProfileCtrl", [
  "$scope", "$rootScope", "$state", "$modal", "$filter"
  "UtilsService", "StateService", "geocoderFactory",
  "offerFactory",
  "isList", "organization", "offers", "promotedOffers", "evaluations",
  ($scope, $rootScope, $state, $modal, $filter,
   UtilsService, StateService, geocoderFactory,
   offerFactory,
   isList, organization, offers, promotedOffers, evaluations) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.user = $rootScope.user
    $scope.offers = offers
    $scope.promotedOffers = promotedOffers
    $scope.organization = organization

    $scope.tab = 'active'
    $scope.isSelfProfile = false
    $scope.isList = isList

    $scope.organizationRatings = evaluations[-2..]

    $scope.doTheBack = ->
      window.history.back()

    if $rootScope.user? && organization.id == $rootScope.user.organization_id
      $scope.isSelfProfile = true

    if $scope.isSelfProfile || ($scope.user? && $scope.user.is_superuser)
      state = StateService.getOfferStates()

      $scope.activeOffers = $filter('filter')(offers,
        (offer) ->
          offer.status in [state.published, state.published_edited] and moment(offer.publish_to) > moment()
      )

      applyCounts = (offer) ->
        counts = offerFactory.getApplicationsCount({offerId: offer.id}).$promise
        counts.then(
          (data) ->
            console.log data
            offer.acceptedVolunteers = data['accepted']
            offer.waitingVolunteers = data['pending to review']
            offer.rejectedVolunteers = data['rejected']
          ->
            offer.acceptedVolunteers = 0
            offer.waitingVolunteers = 0
            offer.rejectedVolunteers = 0
        )
        return

      for offer in $scope.activeOffers
        applyCounts(offer)


    $scope.setTab = (tab) ->
      if tab in ['active', 'inactive', 'finished', 'rejected']
        $scope.tab = tab
      return

    $scope.constructAddress = ->
      str = organization.street + ' ' + organization.house_number
      if organization.apartment_number? and organization.apartment_number.length
        str += '/' + organization.apartment_number
      str += ", " + organization.zipcode + ' ' + organization.city
      return str

    $scope.mapLatLng = {}
    $scope.mapOptions =
      disableDefaultUI: true

    $scope.$watch 'mapLatLng', ->
      $scope.latLength = _.size($scope.mapLatLng);

    geocoderFactory.latLngForAddress($scope.constructAddress()).then(
      (data) ->
        $scope.mapLatLng = data
        $scope.markerPos = angular.copy(data)
    )
    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    return
])
