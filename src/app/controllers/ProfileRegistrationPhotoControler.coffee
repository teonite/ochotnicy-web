# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("ProfileRegistrationPhotoCtrl", [
  "$scope", "$rootScope", "$upload",
  "UtilsService", "Config",
  "profile"
  ($scope, $rootScope, $upload,
   UtilsService, Config,
   profile) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader

    method = 'POST'

    $scope.profile = profile

    if $scope.profile.thumbnail_relation?
      $scope.filename = $scope.profile.thumbnail_relation.filename
    else
      $scope.filename = undefined

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.$watch 'filename', ->
      if $scope.filename?
        method = 'PUT'
      else
        method = 'POST'

    constructUploadUrl = ->
      userPart = '/organizations/'

      if $rootScope.user.is_volunteer
        userPart = '/volunteers/'

      Config.apiRoot + userPart + $scope.profile.id + "/thumbnail/"

    $scope.onFileSelect = ($file) ->
      console.log "onFileSelect enter", $file
      if not $file? or not $file.length
        return

      $scope.upload = $upload.upload(
        url: constructUploadUrl()
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

    return
])
