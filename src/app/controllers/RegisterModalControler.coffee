# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "RegisterModalCtrl", [
  "$scope"
  "$modalInstance"
  "userFactory"
  "socialFactory"
  "UtilsService"
  "$rootScope"
  "$state"
  ($scope, $modalInstance, userFactory, socialFactory, UtilsService, $rootScope, $state) ->
    $scope.mode =
      type: "dedicated"

    if $rootScope.user?
      $modalInstance.dismiss "cancel"

    $scope.formSuccess = false
    $scope.rulesAccepted = false
    $scope.policyAccepted = false
    $scope.fbUrl = socialFactory('facebook')
    $scope.twitterUrl = socialFactory('twitter')

    $scope.$watch "mode", ->
      console.log $scope.mode

    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader

    $scope.bothAccepted = ->
      if $scope.formSuccess
        return false
      return $scope.rulesAccepted && $scope.policyAccepted

    $scope.user =
      username: ""
      password: ""
      email: ""

    $scope.verification = ""

    $scope.registerDedicated = ->
      if $scope.form.$valid
        $scope.form.submitted = true
        userFactory.save({}, $scope.user,
          (value, headers) ->
            console.log value,headers
            $scope.formSuccess = true
            return
          (response) ->
            $scope.errors = response.data
            console.log $scope.errors
            return
        )
      else
        UtilsService.setDirtyFields($scope.form)
        $scope.form.submitted = true

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    $scope.goToLogin = ->
      $state.go('login')
      $modalInstance.dismiss "cancel"
      return

    return
]
