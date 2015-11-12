# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "LoginModalCtrl", [
  "$scope"
  "$modalInstance"
  "AuthService"
  "UtilsService"
  "socialFactory"
  "$cookies"
  "$rootScope"
  "$http"
  "$modal"
  ($scope, $modalInstance, AuthService, UtilsService, socialFactory, $cookies, $rootScope, $http, $modal) ->
    $scope.mode =
      type: "dedicated"

    if $rootScope.user?
      $modalInstance.dismiss "cancel"

    $scope.fbUrl = socialFactory('facebook')
    $scope.twitterUrl = socialFactory('twitter')

    $scope.user =
      username: ""
      password: ""


    $scope.openRegisterModal = (size) ->
      $rootScope.loginOpened = false
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


    $scope.login = ->
      if $scope.loginForm.$valid
        AuthService.login($scope.user).then ((result) ->
          $cookies.token = result["token"]
          $http.defaults.headers.common["Authorization"] = "Token " + result["token"]
          AuthService.checkAuth().then(
            (data) ->
              $rootScope.user = data
              $rootScope.session = AuthService.createSessionFor data
              $modalInstance.dismiss "test"
              return
          )
        ), (errors) ->
          $scope.errors = errors
          for error in $scope.errors.non_field_errors
            switch error.toLowerCase()
              when "user account is disabled." then error = "Konto użytkownika jest nieaktywne."
              when "unable to log in with provided credentials." then error = "Nie można się zalogować przy pomocy podanego loginu i hasła."
            $scope.error = error

          $rootScope.user = undefined
          $rootScope.session = undefined
          return
      else
        UtilsService.setDirtyFields($scope.loginForm)
        $scope.loginForm.submitted = true

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    return
]
