# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "AdminEvaluateOfferModalCtrl", [
  "$scope", "$modalInstance", "$state",
  "Config",
  "offerFactory",
  "status", "id", "statuses",
  ($scope, $modalInstance, $state,
   Config,
   offerFactory,
   status, id, statuses) ->
    $scope.tinymceOptions = Config.tinymceOptions

    $scope.is_proceeded = false
    $scope.success = false
    $scope.fail = false
    $scope.message = ''
    $scope.status = status
    $scope.statuses = statuses

    $scope.sendApplication = ->
      if $scope.form.$valid
        $scope.is_proceeded = true
        offerFactory.update({offerId: id}, {status: status, status_change_reason: $scope.status_change_reason},
          (value, headers) ->
            $scope.success = true
            $scope.is_proceeded = false
            return
          (response) ->
            console.log response
            if response.status == 310
              $scope.success = true
            else
              $scope.fail = true
            $scope.is_proceeded = false
            return
        )
      else
        $scope.form.submitted = true

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    return
]
