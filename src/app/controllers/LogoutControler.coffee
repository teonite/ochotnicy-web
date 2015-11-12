# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "LogoutCtrl", [
  "$scope"
  "$rootScope"
  "$cookies"
  "$state"
  "$http"
  "userFactory"
  ($scope, $rootScope, $cookies, $state, $http, userFactory) ->
    delete $cookies['token']
    delete $http.defaults.headers.common["Authorization"]
    $rootScope.user = null
    $rootScope.session = null

    userFactory.logout()

    $state.go "offer.list"
    return
]
