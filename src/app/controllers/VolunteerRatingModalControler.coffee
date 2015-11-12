# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("VolunteerRatingModalCtrl", [
  "$scope", "$modalInstance", "$state", "$filter",
  "Config",
  "ratingsFactory",
  "offer", "volunteer", "abilities",
  ($scope, $modalInstance, $state, $filter, Config, ratingsFactory, offer, volunteer, abilities) ->
    $scope.tinymceOptions = Config.tinymceOptions

    $scope.is_proceeded = false
    $scope.success = false
    $scope.fail = false
    $scope.message = ''
    $scope.offer = offer
    $scope.volunteer = volunteer
    $scope.filled = false
    $scope.average = 0.0
    $scope.testimonial = ""

    _.map abilities, (element) ->
      element.rating = 0
      return

    $scope.volunteerAbilities = $filter('filter')(abilities,
      (ability) ->
        ability.choosen
    )
    $scope.volunteerAverage = 0.0
    $scope.volunteerFilled = false

    $scope.otherAbilities = $filter('filter')(abilities,
        (ability) ->
          not ability.choosen
    )
    $scope.otherAbilitiesOrig = angular.copy($scope.otherAbilities)
    $scope.otherAbilitiesChosen = []
    $scope.otherAbilitiesSelect = {id: 0, name: 'Wybierz umiejętności do oceny'}
    $scope.otherAverage = 0.0
    $scope.otherFilled = true

    $scope.$watch "otherAbilitiesSelect", (newValue) ->
      idx = _.findIndex($scope.otherAbilities, (obj) -> obj.id == newValue)

      if idx > -1 and $scope.otherAbilities[idx] not in $scope.otherAbilitiesChosen
        $scope.otherAbilitiesChosen.push $scope.otherAbilities[idx]
        $scope.otherAbilities = _.difference $scope.otherAbilitiesOrig, $scope.otherAbilitiesChosen
        $scope.otherAbilitiesSelect = {id: 0, name: 'Wybierz umiejętności do oceny'}
        $scope.otherFilled = false
      return

    $scope.$watch "otherAbilitiesChosen", ->
      $scope.otherAbilities = _.difference $scope.otherAbilitiesOrig, $scope.otherAbilitiesChosen
      return

    $scope.$watch("otherAbilitiesChosen", ->
      console.log "$watchCollection otherAbilitiesChosen"
      $scope.otherAverage = 0
      $scope.otherFilled = true
      _.map $scope.otherAbilitiesChosen, (element) ->
        $scope.otherAverage += element.rating
        if element.rating <= 0
          $scope.otherFilled = false
        return
      if $scope.otherAbilitiesChosen.length
        $scope.otherAverage /= $scope.otherAbilitiesChosen.length
      return
    true)

    $scope.$watch("volunteerAbilities", ->
      console.log "$watchCollection volunteerAbilities"
      $scope.volunteerAverage = 0
      $scope.volunteerFilled = true
      _.map $scope.volunteerAbilities, (element) ->
        $scope.volunteerAverage += element.rating
        if element.rating <= 0
          $scope.volunteerFilled = false
        return
      $scope.volunteerAverage /= $scope.volunteerAbilities.length
      return
    true)

    $scope.$watchGroup ["volunteerAverage", "otherAverage"], ->
      console.log "$watchGroup average"
      if $scope.success || $scope.fail || $scope.is_proceeded
        return

      if not $scope.otherAbilitiesChosen.length
        $scope.average = $scope.volunteerAverage
      else
        $scope.average = ($scope.volunteerAverage + $scope.otherAverage) / 2
      return

    $scope.$watchGroup ["volunteerFilled", "otherFilled"], ->
      console.log "$watchGroup filled"
      if $scope.volunteerFilled and $scope.otherFilled
        $scope.filled = true
      else
        $scope.filled = false
      return

    $scope.removeOtherAbility = (ability) ->
      $scope.otherAbilitiesChosen = _.without $scope.otherAbilitiesChosen, ability
      return

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    $scope.submit = ->
      if not $scope.filled
        return

      $scope.is_proceeded = true

      data =
        volunteer: volunteer.id
        offer: offer.id

      data.abilities = _.union($scope.volunteerAbilities, $scope.otherAbilitiesChosen)

      _.map data.abilities, (element) ->
        delete element.choosen
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

