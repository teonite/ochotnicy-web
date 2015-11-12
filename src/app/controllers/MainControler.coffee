# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("MainCtrl", [
  "$scope"
  "$rootScope"
  "$state"
  "$modal"
  "Config"
  "AuthService"
  "settingsFactory"
  "$window"
  "UtilsService"
  "$cookies"
  "notify"
  "ipCookie"
  ($scope, $rootScope, $state, $modal, Config, AuthService, settingsFactory, $window, UtilsService, $cookies, notify, ipCookie) ->


    $scope.modal = () ->
        notify({duration: '0',templateUrl: 'privacyModal.html' });
        ipCookie('privacyOpen', 'True', { expires: 315})

    if ipCookie('privacyOpen') then $scope.cook = ipCookie('privacyOpen') else $scope.modal()



    $scope.isAuthorized = (role) ->
      AuthService.isAuthorized role, $scope.session

    $scope.isCollapsed = true
    $scope.hideBanner = false

    $rootScope.$watch "user", (oldValue, newValue) ->
      $scope.user = $rootScope.user
      return

    $rootScope.$watch "smallBanner", ->
      $scope.smallBanner = $rootScope.smallBanner
      return

    $rootScope.$watch "hideBanner", ->
      $scope.hideBanner = $rootScope.hideBanner
      return

    $rootScope.$watch "banner", ->
      $scope.banner = $rootScope.banner
      return
    , true

    $rootScope.$watch "preventLoader", ->
      if $rootScope.preventLoader
        $scope.rootLoader = false
      return

    $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
      if !$rootScope.preventLoader
        $scope.isCollapsed = true
        $scope.rootLoader = true

      return

    $rootScope.$on "$stateChangeSuccess", (event, toState, toParams, fromState, fromParams) ->
      $scope.rootLoader = false
      return

    $scope.openErrorModal = (size) ->
      modalInstance = $modal.open(
        templateUrl: "errorModal.html"
        controller: "ErrorModalCtrl"
        size: size
        resolve:
          error: ($rootScope) ->
            $rootScope.error
      )
      modalInstance.result.then (->
        return
      ), ->
        $window.location.reload()
        return

      return

    settingsFactory.get({'id': 'instance_name'},
      (data) ->
        $scope.instanceName = data.value
        $rootScope.instanceName = data.value
        return
      (err) ->
        $scope.instanceName = "Warszawscy"
        $rootScope.instanceName = "Warszawscy"
        console.log err
        return
    )

    settingsFactory.get({'id': 'facebook_profileurl'},
      (data) ->
        $scope.profileUrl = data.value
        return
      (err) ->
        console.log err
        return
    )

    $rootScope.$watch "errorModal", ->
      console.log $rootScope.errorModal
      if $rootScope.errorModal
        $scope.openErrorModal()

      return

    $scope.$on "loginSuccess", ->
      $state.go "offer.list"
      return

    $scope.$on "userAuthenticated", ->
      $state.go "offer.list"
      return

    $rootScope.loginOpened = false

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

    $scope.frontendVersion = Config.version
    $rootScope.$watch "backendVersion", ->
      $scope.backendVersion = $rootScope.backendVersion
      return

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)
])
