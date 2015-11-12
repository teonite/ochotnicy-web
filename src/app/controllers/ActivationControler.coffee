# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("ActivationCtrl", [
  "$scope"
  "$rootScope"
  "$state"
  "$modal"
  "$stateParams"
  "instanceName"
  ($scope, $rootScope, $state, $modal, $stateParams, instanceName) ->
    $scope.openActivationModal = ->
      modalInstance = $modal.open(
        templateUrl: "activationModal.html"
        controller: "ActivationModalCtrl"
        backdrop: "static"
        resolve:
          hash: ->
            $stateParams.hash
          instanceName: ->
            instanceName.value
      )
      modalInstance.result.then ((selectedItem) ->
        $scope.selected = selectedItem
        return
      ), ->
        console.log "Modal dismissed at: " + new Date()
        return

      return

    $scope.openActivationModal()

    return
])
