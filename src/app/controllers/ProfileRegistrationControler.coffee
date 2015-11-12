# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("ProfileRegistrationCtrl", [
  "$scope"
  "$rootScope"
#  "promotedOffers"
  "UtilsService"
  "Config"
  "abilities"
  "education"
  "organizationTypes"
  "userFactory"
  "organizationFactory"
  "volunteerFactory"
  "$state"
  "countries"
  "AuthService"
  ($scope, $rootScope, UtilsService, Config, abilities, education, organizationTypes, userFactory, organizationFactory, volunteerFactory, $state, countries, AuthService) ->
    if $rootScope.user.is_volunteer || $rootScope.user.is_organization
      $state.go("offer.list")

    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.tinymceOptions = Config.tinymceOptions
    $scope.volunteer = null
    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader
    $scope.opened = false
    $scope.maxDate = moment().subtract(13, 'years').toDate()
    $scope.dateOptions =
      datepickerMode: "'year'"
      startingDay: 1

    $scope.abilities = abilities
    $scope.education = education
    $scope.organizationTypes = organizationTypes
    $scope.countries = countries
    $scope.user =
      first_name: null
      last_name: null
    $scope.profile =
      gender: 1
      education: (if education.length then education[0].id else null)
    $scope.organizationType = (if organizationTypes.length then organizationTypes[0] else null)
    $scope.organization =
      type: (if $scope.organizationType.length then $scope.organizationType.id else null)
      country: 'PL'

    $scope.$watch "organizationType", (oldValue, newValue) ->
      $scope.organization.type = $scope.organizationType.id

    $scope.openCalendar = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()

      $scope.opened = true
      return

    $scope.validateDate = (value) ->
      moment(value, ["DD/MM/YYYY"], true)

    $rootScope.$on('$stateChangeStart',
      (event, toState, toParams, fromState, fromParams) ->
        if fromState.name == 'profileRegister'
          if !$scope.success && toState.name != 'logout' && $rootScope.user? && !$rootScope.user.is_superuser
            event.preventDefault()
            $rootScope.preventLoader = true
            return

          $rootScope.preventLoader = false
          return
        return
    )

    $scope.submit = ->
      $scope.userSuccess = false
      $scope.profileSuccess = false

      if $scope.form.$valid
        if $scope.volunteer
          $scope.profile.birthday = moment($scope.profile.birthday).format("YYYY-MM-DD")
          promise = volunteerFactory.save({}, $scope.profile).$promise
        else
          promise = organizationFactory.save({}, $scope.organization).$promise

        promise.then(
          (data) ->
            $scope.profileSuccess = true

            userFactory.update({"userId": $rootScope.user.id}, $scope.user,
              (data) ->
                $scope.userSuccess = true
                AuthService.checkAuth().then(
                  (data) ->
                    $rootScope.user = data
                    $rootScope.session = AuthService.createSessionFor data
                    return
                )
                return
              (err, status) ->
                $scope.userError = err
                return
            )

            return

          (data, status) ->
            $scope.error = data
            return
        )

        $scope.$watchGroup ['profileSuccess', 'userSuccess'],
          ->
            if $scope.profileSuccess && $scope.userSuccess
              $scope.success = true
              $scope.error = undefined
              $scope.userError = undefined
            return

        return
      else
        console.log "invalid"
        UtilsService.setDirtyFields($scope.form)
        $scope.form.submitted = true
        return

    return
])
