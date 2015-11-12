# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("AdminNewsAddCtrl", [
  "$scope", "$rootScope", "$upload",
  "UtilsService", "Config",
  "newsFactory",
  "news",
  ($scope, $rootScope, $upload,
   UtilsService, Config,
   newsFactory,
   news
  ) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $rootScope.$watch "showLoader", ->
      $scope.showLoader = $rootScope.showLoader

    $scope.tinymceOptions = Config.tinymceOptions
    $scope.news = news
    $scope.isEdited = news.id?

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.doTheBack = ->
      window.history.back()

    method = 'POST'

    if $scope.news.news_thumbnail?
      $scope.filename = $scope.news.news_thumbnail.filename
    else
      $scope.filename = undefined

    $scope.$watch 'filename', ->
      if $scope.filename?
        method = 'PUT'
      else
        method = 'POST'

    $scope.onFileSelect = ($file) ->
      console.log "onFileSelect enter", $file
      if not $file? or not $file.length or not ($scope.news? and $scope.news.id)
        return

      $scope.upload = $upload.upload(
        url: Config.apiRoot + "/news/" + $scope.news.id + "/thumbnail/"
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
      acceptedFields = ['title', 'body']

      $scope.success = false
      $scope.error = false

      if $scope.form.$valid
        if $scope.news.id
          promise = newsFactory.update({id: $scope.news.id}, _.pick($scope.news, acceptedFields)).$promise
        else
          promise = newsFactory.save({}, _.pick($scope.news, acceptedFields)).$promise

        promise.then(
          (data) ->
            $scope.success = true
            $scope.news = data
            return

          (data, status) ->
            $scope.error = data
            return
        )
        return
      else
        console.log "invalid"
        $scope.form.submitted = true
        return

    return
])
