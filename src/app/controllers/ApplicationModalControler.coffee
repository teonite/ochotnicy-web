# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "ApplicationModalCtrl", ($scope, $modalInstance, $state, offerFactory, offer) ->
  $scope.is_proceeded = true
  $scope.success = false
  $scope.fail = false
  $scope.notExtended = false
  $scope.offer = offer

  offerFactory.apply({offerId: offer.id},
    (value, headers) ->
      console.log value, headers
      $scope.success = true
      $scope.is_proceeded = false
      return
    (response) ->
      console.log response
      if response.status == 440
        $state.go 'volunteer.edit'
        $scope.notExtended = true
      else
        $scope.fail = true

      $scope.is_proceeded = false
      return
  )

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"
    return

  return

