# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("NewsListCtrl", [
  "$scope", "$rootScope",
  "UtilsService", "Config"
  "newsList", "promotedOffers"
  ($scope, $rootScope, UtilsService, Config, newsList, promotedOffers) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader

    $scope.newsList = newsList
    $scope.promotedOffers = promotedOffers
    $scope.page = 1
    $scope.orderingOptions = [
      {name: 'Najnowsze', field: '-created_at'},
      {name: 'Najstarsze', field: 'created_at'}
    ]
    $scope.ordering = $scope.orderingOptions[0]

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    return
])
