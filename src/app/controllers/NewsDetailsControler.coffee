# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("NewsDetailsCtrl", [
  "$scope", "$rootScope",
  "UtilsService", "Config"
  "news", "promotedOffers"
  ($scope, $rootScope, UtilsService, Config, news, promotedOffers) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.news = news
    $scope.promotedOffers = promotedOffers

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    return
])
