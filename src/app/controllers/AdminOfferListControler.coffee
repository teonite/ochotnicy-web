# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("AdminOfferListCtrl", [
  "$scope", "$rootScope", "$filter", "$modal", "$window",
  "UtilsService", "Config", "StateService",
  "offerFactory"
  "offerList"
  ($scope, $rootScope, $filter, $modal, $window,
   UtilsService, Config, StateService,
   offerFactory,
   offerList) ->
    $rootScope.hideBanner = true
    $scope.tab = 'pending'

    state = StateService.getOfferStates()
    $scope.state = state
    $scope.sorting = {}

    $scope.orderingOptions = [
      {name: 'Data dodania - rosnąco', field: 'created_at'},
      {name: 'Data dodania - malejąco', field: '-created_at'},
      {name: 'Alfabetycznie - rosnąco', field: 'title'},
      {name: 'Alfabetycznie - malejąco', field: '-title'}
    ]
    $scope.sorting.ordering = $scope.orderingOptions[0]

    $scope.orderingActiveOptions = [
      {name: 'Data publikacji - rosnąco', field: 'published_at'},
      {name: 'Data publikacji - malejąco', field: '-published_at'},
      {name: 'Alfabetycznie - rosnąco', field: 'title'},
      {name: 'Alfabetycznie - malejąco', field: '-title'}
    ]
    $scope.sorting.orderingActive = $scope.orderingActiveOptions[0]

    $scope.updateFilters = ->
      $scope.pendingOffers = $filter('orderBy')($scope.pendingOffers, $scope.sorting.ordering.field)
      $scope.activeOffers = $filter('orderBy')($scope.activeOffers, $scope.sorting.orderingActive.field)
      $scope.blockedOffers = $filter('orderBy')($scope.blockedOffers, $scope.sorting.ordering.field)
      $scope.finishedOffers = $filter('orderBy')($scope.finishedOffers, $scope.sorting.orderingActive.field)
      return

    update = ->
      offerFactory.getAdminList().$promise.then(
        ((data) ->
          offerList = data
          $scope.pendingOffers = $filter('filter')(offerList,
            (offer) ->
              offer.status == state.in_review
          )
          $scope.activeOffers = $filter('filter')(offerList,
            (offer) ->
              offer.status in [state.published, state.published_edited] and moment(offer.publish_to) > moment()
          )
          $scope.blockedOffers = $filter('filter')(offerList,
            (offer) ->
              offer.status in [state.unpublished, state.rejected]
          )
          $scope.finishedOffers = $filter('filter')(offerList,
            (offer) ->
              offer.status in [state.published, state.published_edited] and moment(offer.publish_to) < moment()
          )
          $scope.updateFilters()
          return
        ),
        (error) ->
          return
      )
      return

    update()

    $scope.$watch("sorting", (-> $scope.updateFilters()), true)

    $scope.setTab = (tab) ->
      switch tab
        when 'pending' then $scope.tab = 'pending'
        when 'active' then $scope.tab = 'active'
        when 'blocked' then $scope.tab = 'blocked'
        when 'finished' then $scope.tab = 'finished'
        else $scope.tab = 'pending'

      return

    $scope.changePromote = (offer) ->
      offerFactory.update({offerId: offer.id}, {is_promoted: !offer.is_promoted},
        (data) ->
          update()
          return
        (error) ->
          update()
          return
      )

    $scope.acceptOffer = (id) ->
      offerFactory.update({offerId: id}, {status: state.published, status_change_reason: ''},
        (value, headers) ->
          $window.alert('Zaakceptowano ofertę')
          update()
          return
        (response) ->
          $window.alert('Nie udało się zaakceptować oferty')
          update()
          return
      )
      return

    $scope.evaluateOfferModal = (status, id) ->
      modalInstance = $modal.open(
        templateUrl: "adminEvaluateOfferModal.html"
        controller: "AdminEvaluateOfferModalCtrl"
        windowTemplateUrl: "modalWindowBright.html"
        backdrop: "static"
        resolve:
          status: ->
            status
          id: ->
            id
          statuses: ->
            state
      )
      modalInstance.result.then ( ->
        update()
        return
      ), ->
        update()
        return

      return

    return
])
