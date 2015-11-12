# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("PlainHtmlCtrl", [
  "$scope", "$rootScope", "$anchorScroll", "$location", "$modal",
  "UtilsService", "Config",
  "promotedOffers", "scrollTo", "banner",
  ($scope, $rootScope, $anchorScroll, $location, $modal,
   UtilsService, Config,
   promotedOffers, scrollTo, banner) ->
    $rootScope.smallBanner = if banner.hasOwnProperty('small') then banner.small else true
    $rootScope.hideBanner = false

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $rootScope.banner =
      class: if banner.hasOwnProperty('class') then banner.class else ""
      title: if banner.hasOwnProperty('title') then banner.title else null
      description: if banner.hasOwnProperty('description') then banner.description else null
      hideHowLink: if banner.hasOwnProperty('hideHowLink') then banner.hideHowLink else false
      hideFB: if banner.hasOwnProperty('hideFB') then banner.hideFB else false
      hideMain: if banner.hasOwnProperty('hideMain') then banner.hideMain else false



    $scope.promotedOffers = promotedOffers
    $scope.stocznia =
      center:
        latitude: 52.2321559
        longitude: 21.017218
      marker:
        latitude: 52.2321559
        longitude: 21.017218
      zoom: 17
      markerOptions:
        labelContent: "Bracka 20b"
      options:
        disableDefaultUI: true

    if scrollTo.length
      $location.hash(scrollTo);
      $anchorScroll()

    $scope.openRegisterModal = (size) ->
      modalInstance = $modal.open(
        templateUrl: "registerModal.html"
        controller: "RegisterModalCtrl"
        size: size
        backdrop: "static"
        resolve:
          items: ->
            []
      )
      modalInstance.result.then ((selectedItem) ->
        $scope.selected = selectedItem
        return
      ), ->
        console.log "Modal dismissed at: " + new Date()
        return

      return

    return
])
