# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OrganizationRatingModalCtrl", [
  "$scope", "$modalInstance", "$state", "$filter",
  "Config",
  "ratingsFactory",
  "offer", "organization", "abilities",
  ($scope, $modalInstance, $state, $filter, Config, ratingsFactory, offer, organization, abilities) ->
    $scope.tinymceOptions = Config.tinymceOptions

    $scope.is_proceeded = false
    $scope.success = false
    $scope.fail = false
    $scope.message = ''
    $scope.offer = offer
    $scope.organization = organization
    console.log(organization, offer)
    $scope.filled = false
    $scope.average = 0.0
    $scope.testimonial = ""
    $scope.abilities = abilities

    _.map $scope.abilities, (element) ->
      element.rating = 0
      return


    $scope.$watch("abilities", ->
      console.log "$watch abilities"
      $scope.average = 0
      $scope.filled = true
      _.map $scope.abilities, (element) ->
        $scope.average += element.rating
        if element.rating <= 0
          $scope.filled = false
        return
      $scope.average /= $scope.abilities.length
      return
    true)

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    $scope.submit = ->
      if not $scope.filled
        return

      $scope.is_proceeded = true

      data =
        organization: organization.id
        offer: offer.id
        abilities: $scope.abilities

      _.map data.abilities, (element) ->
        delete element.name
        return

      console.log data.abilities
      if $scope.testimonial.length
        data.testimonial = $scope.testimonial

      ratingsFactory.save({}, data).$promise.then(
        (data) ->
          $scope.success = true
          $scope.is_proceeded = false
          return
        (err) ->
          $scope.fail = true
          $scope.is_proceeded = false
          return
      )
      return

    return
])

