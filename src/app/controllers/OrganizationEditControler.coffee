# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OrganizationEditCtrl", [
  "$scope"
  "$rootScope"
  "$upload"
  "organization"
  "promotedOffers"
  "countries"
  "organizationTypes"
  "organizationFactory"
  "userFactory"
  "UtilsService"
  "AuthService"
  "Config"
  ($scope, $rootScope, $upload, organization, promotedOffers, countries, organizationTypes, organizationFactory, userFactory, UtilsService, AuthService, Config) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.tinymceOptions = Config.tinymceOptions
    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader
    $scope.opened = false
    $scope.maxDate = moment().subtract(13, 'years')

    $scope.promotedOffers = promotedOffers

    $scope.organization = organization
    $scope.user = $rootScope.user
    $scope.countries = countries
    $scope.organizationTypes = organizationTypes

    for type in organizationTypes
      if type.name == organization.type
        $scope.organizationType = type
        break

    if !$scope.organization.country? or !$scope.organization.country.length
      $scope.organization.country = 'PL'

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.doTheBack = ->
      window.history.back()

    $scope.openCalendar = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()

      $scope.opened = true
      return

    method = 'POST'

    if $scope.organization.thumbnail_relation?
      $scope.filename = $scope.organization.thumbnail_relation.filename
    else
      $scope.filename = undefined

    $scope.$watch 'filename', ->
      if $scope.filename?
        method = 'PUT'
      else
        method = 'POST'

    $scope.onFileSelect = ($file) ->
      console.log "onFileSelect enter", $file
      if not $file? or not $file.length
        return

      $scope.upload = $upload.upload(
        url: Config.apiRoot + "/organizations/" + $scope.organization.id + "/thumbnail/"
        method: method
        file: $file
        fileFormDataName: 'filename'
      ).progress((evt) ->
        $scope.progressBar = true
        $scope.progress = parseInt(100.0 * evt.loaded / evt.total)
        console.log "progress: " + parseInt(100.0 * evt.loaded / evt.total) + "% file :" + evt.config.file.name
        return
      ).success((data, status, headers, config) ->
        $scope.uploadSuccess = true
        $scope.uploadFailed = false
        $scope.filename = data.thumbnail.filename
        # file is uploaded successfully
        console.log "file " + config.file.name + "is uploaded successfully. Response: ", data
        return
      ).error((err, status) ->
        if parseInt(status) == 413
          $scope.uploadFailed = false
          $scope.fileTooBig = true
        else
          $scope.uploadFailed = true
          $scope.fileTooBig = false

        $scope.uploadSuccess = false
        console.log 'Error occured during upload:', err, status
      )
      return

    $scope.submit = ->
      acceptedFields = ['type', 'coordinator', 'fullname', 'shortname', 'street', 'house_number',
                        'zipcode', 'city', 'country', 'nip', 'krs', 'apartment_number', 'district', 'province',
                        'phonenumber', 'description']
      $scope.userSuccess = false
      $scope.profileSuccess = false
      if $scope.form.$valid
        $scope.organization.type = $scope.organizationType.id
        $scope.organization.coordinator = $scope.user.id
        console.log _.pick($scope.organization, acceptedFields)
        promise = organizationFactory.update({organizationId: 'my'}, _.pick($scope.organization, acceptedFields)).$promise

        promise.then(
          (data) ->
            $scope.profileSuccess = true

            acceptedFields = ['first_name', 'last_name']
            userFactory.update({"userId": $rootScope.user.id}, _.pick($scope.user, acceptedFields),
              (data) ->
                $scope.userSuccess = true
                return
              (err, status) ->
                $scope.userError = err
                return
            )

            AuthService.checkAuth().then(
              (data) ->
                $rootScope.user = data
                $rootScope.session = AuthService.createSessionFor data
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
        $scope.form.submitted = true
        return

    return
])
