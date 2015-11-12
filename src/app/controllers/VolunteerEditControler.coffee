# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("VolunteerEditCtrl", [
  "$scope", "$rootScope", "$upload"
  "UtilsService", "Config", "AuthService", "StateService",
  "volunteerFactory", "userFactory",
  "profile", "promotedOffers", "education", "abilities", "countries",
  ($scope, $rootScope, $upload,
   UtilsService, Config, AuthService, StateService,
   volunteerFactory, userFactory,
   profile, promotedOffers, education, abilities, countries) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.tinymceOptions = Config.tinymceOptions
    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader
    $scope.opened = false
    $scope.maxDate = moment().subtract(13, 'years').toDate()

    $scope.promotedOffers = promotedOffers

    $scope.profile = profile
    $scope.user = $rootScope.user
    $scope.abilities = abilities
    $scope.education = education
    $scope.countries = countries
    $scope.proofTypes = StateService.getProofTypes()

    $scope.profile.education = $scope.profile.education.id
    $scope.profile.abilities = (ability.id for ability in $scope.profile.abilities)

    if !$scope.profile.country? or !$scope.profile.country.length
      $scope.profile.country = 'PL'

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

    if $scope.profile.thumbnail_relation?
      $scope.filename = $scope.profile.thumbnail_relation.filename
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
        url: Config.apiRoot + "/volunteers/" + $scope.profile.id + "/thumbnail/"
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

    $scope.validatePESEL = ($value) ->
      reg = /^[0-9]{11}$/
      if reg.test($value) is false
        false
      else
        dig = ("" + $value).split("")
        controlSum = parseInt(dig[0] + 3 * parseInt(dig[1]) + 7 * parseInt(dig[2]) + 9 * parseInt(dig[3]) + parseInt(dig[4]) + 3 * parseInt(dig[5]) + 7 * parseInt(dig[6]) + 9 * parseInt(dig[7]) + 1 * parseInt(dig[8]) + 3 * parseInt(dig[9])) % 10
        controlSum = 10  if controlSum is 0
        controlSum = 10 - controlSum
        if parseInt(dig[10]) is controlSum
          false
        else
          true

    $scope.submit = ->
      field_subset = ['birthday', 'about', 'abilities', 'education', 'gender', 'phonenumber', 'abilities_description']

      $scope.userSuccess = false
      $scope.profileSuccess = false
      $scope.extendedSuccess = false

      if $scope.form.$valid
        $scope.profile.birthday = moment($scope.profile.birthday).format("YYYY-MM-DD")
        promise = volunteerFactory.update({id: 'my'}, _.pick($scope.profile, field_subset)).$promise

        promise.then(
          (data) ->
            $scope.profileSuccess = true
            field_subset = ['first_name', 'last_name']
            userFactory.update({"userId": $rootScope.user.id}, _.pick($scope.user, field_subset),
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

            field_subset = ['street', 'house_number', 'apartment_number', 'zipcode', 'city', 'country', 'proof_number', 'proof_type']
            volunteerFactory.update({id: 'my'}, _.pick($scope.profile, field_subset),
              (data) ->
                $scope.extendedSuccess = true
                return
              (err, status) ->
                $scope.extendedError = err
                return
            )

            return
          (data, status) ->
            $scope.error = data
            return
        )

        $scope.$watchGroup ['profileSuccess', 'userSuccess', 'extendedSuccess'],
          ->
            if $scope.profileSuccess && $scope.userSuccess
              $scope.success = true
              $scope.error = undefined
              $scope.userError = undefined
              $scope.extendedError = undefined
            return

        return
      else
        console.log "invalid"
        console.log $scope.form
        UtilsService.setDirtyFields($scope.form)
        $scope.form.submitted = true
        return

    return
])
