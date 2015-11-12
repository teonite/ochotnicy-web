# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "EvaluateApplicationModalCtrl", ($scope, $modalInstance, $state, Config, applicationFactory, status, id) ->
  $scope.tinymceOptions = Config.tinymceOptions

  $scope.is_proceeded = false
  $scope.success = false
  $scope.fail = false
  $scope.message = ''
  $scope.status = status
  console.log(id)
  $scope.sendApplication = ->
    if $scope.form.$valid
      $scope.is_proceeded = true
      applicationFactory.update({}, {id: id, status: status, message: $scope.message},
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
    else
      $scope.form.submitted = true

  $scope.cancel = ->
    $modalInstance.dismiss "cancel"
    return

  return

