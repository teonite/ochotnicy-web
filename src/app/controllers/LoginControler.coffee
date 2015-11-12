# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("LoginCtrl", [
  "$scope", "$rootScope", "$state", "$modal", "$cookies", "$timeout",
  ($scope, $rootScope, $state, $modal, $cookies, $timeout) ->
    $scope.openLoginModal = (size) ->
      if $rootScope.loginOpened
        return

      $rootScope.loginOpened = true

      modalInstance = $modal.open(
        templateUrl: "loginModal.html"
        controller: "LoginModalCtrl"
        size: size
        backdrop: "static"
        resolve:
          items: ->
            []
      )
      modalInstance.result.then(
        ->
          $rootScope.loginOpened = false
          return
        ->
          console.log "Login modal dismissed at: " + new Date()
  #        delete $cookies['token']
          $rootScope.loginOpened = false

          if !$rootScope.user?
            $state.go('offer.list')
            return

          if $rootScope.user.is_superuser
            $state.go('admin.offers')
          else if $rootScope.user.is_organization
            $state.go("organization.profile", {id: 'my'})
          else
            $state.go('offer.list')
          return
      )

      return

    if !$cookies.token
      $scope.openLoginModal()
    else
      console.log 'Authenticated'
      $timeout(
        (->
          if !$rootScope.user?
            $state.go('offer.list')
            return

          if $rootScope.user.is_superuser
            $state.go('admin.offers')
          else if $rootScope.user.is_organization
            $state.go("organization.profile", {id: 'my'})
          else
            $state.go('offer.list')

          return
        ), 1500, false)
    return
])
