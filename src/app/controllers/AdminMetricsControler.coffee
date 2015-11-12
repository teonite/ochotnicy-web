# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("AdminMetricsCtrl", [
  "$scope", "$rootScope",
  "UtilsService", "Config",
  "metrics"
  ($scope, $rootScope,
   UtilsService, Config,
   metrics) ->
    $rootScope.hideBanner = true

    $scope.metrics = {}
    for metric in metrics
      $scope.metrics[metric.slug] = metric.current_value

    console.log $scope.metrics

    return
])
