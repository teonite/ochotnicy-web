# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "ErrorModalCtrl", [
  "$scope", "$modalInstance", "$sanitize",
  "error"
  ($scope, $modalInstance, $sanitize, error) ->
    $scope.error = error
    $scope.isHtml = error.type == 'text/html'
    $scope.error.msg = $sanitize($scope.error.msg)
    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    return
]
