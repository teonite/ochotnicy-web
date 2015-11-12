# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "ActivationModalCtrl", [
  "$scope", "$modalInstance", "$state",
  "userFactory",
  "hash", "instanceName",
  ($scope, $modalInstance, $state,
   userFactory,
   hash, instanceName) ->
    $scope.is_proceeded = true
    $scope.success = false
    $scope.fail = false
    $scope.instanceName = instanceName

    userFactory.activate({hash: hash}, $scope.user,
      (value, headers) ->
        console.log value, headers
        $scope.success = true
        $scope.is_proceeded = false
        return
      (response) ->
        console.log response
        $scope.fail = true
        $scope.is_proceeded = false
        return
    )

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    $scope.goToLogin = ->
      $state.go('login')
      $modalInstance.dismiss "cancel"
      return

    return
]

