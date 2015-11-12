# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OfferEditCtrl", [
  "$scope", "$rootScope", "$state", "$upload",
  "Config", "UtilsService", "StateService",
  "offerFactory", "agreementTaskFactory", "organizationFactory"
  "offer", "promotedOffers", "step", "categories", "isNew", "organization"
  ($scope, $rootScope, $state, $upload,
   Config, UtilsService, StateService
   offerFactory, agreementTaskFactory, organizationFactory,
   offer, promotedOffers, step, categories, isNew, organization) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.isNew = isNew
    $scope.opened =
      pub: false
      close: false
    $scope.dateOptions =
      startingDay: 1
    $scope.chartOptions =
      percentageInnerCutout: 70
      showScale: false
      showTooltips: false
    $scope.tinymceOptions = Config.tinymceOptions
    $scope.pubMinDate = moment().startOf('day').toDate()
    $scope.closeMinDate = moment().add(1, 'days').endOf('day').toDate()

    goToNextStep = (offerId, nextStep) ->
      if nextStep
        $state.go "offer.edit",
          step: nextStep
          id: offerId
      else
        if $scope.step < 5
          $state.go "offer.edit",
            step: $scope.step + 1
            id: offerId
      return

    $scope.offer = offer
    if !$scope.offer?
      $scope.offer = {}

    $scope.step = step
    $scope.promotedOffers = promotedOffers

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.goToStep = (step) ->
      goToNextStep $scope.offer.id, step
      return

    $scope.openCalendar = ($event, type) ->
      $event.preventDefault()
      $event.stopPropagation()

      switch type
        when 'close' then $scope.opened.close = true
        when 'pub' then $scope.opened.pub = true

      return
    switch step
      when 1
        field_subset = ['title', 'publish_from', 'publish_to', 'volunteer_max_count', 'category', 'localization',
                        'description_quests', 'description_time', 'description',]

        if offer.category?
          offer.category = (cat.id for cat in offer.category)
        if !isNew
          $scope.pubMinDate = moment($scope.offer.publish_from).startOf('day').toDate()

        constructOrgAddress = ->
          str = organization.street + ' ' + organization.house_number
          if organization.apartment_number? && organization.apartment_number.length
            str += '/' + organization.apartment_number
          str += ", " + organization.zipcode + ' ' + organization.city
          return str

        if not offer.localization? or not offer.localization.length
          $scope.offer.localization = constructOrgAddress()

        $scope.categories = categories

        #TODO: move to angular-chosen
        $scope.$watch "form.category.$dirty", (newValue) ->
          if newValue
            $('#offer_category_chosen').addClass("ng-dirty")
          else
            $('#offer_category_chosen').removeClass("ng-dirty")
          return

        $scope.$watch "form.category.$valid", (newValue) ->
          if newValue
            $('#offer_category_chosen').addClass("ng-valid")
          else
            $('#offer_category_chosen').removeClass("ng-valid")
          return

        $scope.$watch "form.category.$invalid", (newValue) ->
          if newValue
            $('#offer_category_chosen').addClass("ng-invalid")
          else
            $('#offer_category_chosen').removeClass("ng-invalid")
          return

        $scope.$watch "form.category.$pristine", (newValue) ->
          if newValue
            $('#offer_category_chosen').addClass("ng-pristine")
          else
            $('#offer_category_chosen').removeClass("ng-pristine")
          return

        $scope.save = ->
          if $scope.form.$valid
            console.log $scope.offer
            $scope.offer.publish_from = moment($scope.offer.publish_from).startOf('day')
            $scope.offer.publish_to = moment($scope.offer.publish_to).endOf('day')

            if $scope.offer && $scope.offer.id
                promise = offerFactory.update({offerId: $scope.offer.id}, _.pick($scope.offer, field_subset)).$promise
            else
                promise = offerFactory.save({}, _.pick($scope.offer, field_subset)).$promise

            promise.then(
              (offer) ->
                goToNextStep(offer.id, 2)
              ,
              (errors) ->
                console.log errors
                $scope.offer.publish_from = moment($scope.offer.publish_from).format("DD/MM/YYYY")
                $scope.offer.publish_to = moment($scope.offer.publish_to).format("DD/MM/YYYY")
                return
            )
          else
            UtilsService.setDirtyFields($scope.form)
            $scope.form.submitted = true
          return

      when 2
        field_subset = ['description_requirements', 'description_benefits', 'description_additional_requirements']

        $scope.save = ->
          if $scope.form.$valid
            promise = offerFactory.update({offerId: $scope.offer.id}, _.pick($scope.offer, field_subset) ).$promise

            promise.then(
              (offer) ->
                console.log offer
                goToNextStep(offer.id, 3);
              ,
              (errors) ->
                console.log errors
                return
            )
          else
            UtilsService.setDirtyFields($scope.form)
            $scope.form.submitted = true
          return
      when 3
        method = 'POST'

        if $scope.offer.large_thumbnail_relation?
          $scope.filename = $scope.offer.large_thumbnail_relation.filename
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
            url: Config.apiRoot + "/offers/" + $scope.offer.id + "/thumbnail/"
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
            $scope.filename = data.large.filename
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
          if $scope.filename
            goToNextStep($scope.offer.id, 4)

      when 4
        $scope.newTask = false
        $scope.addAgreement = 'false'

        $scope.pubMinDate = moment(offer.publish_from).startOf('day').toDate()
        $scope.closeMinDate = moment(offer.publish_from).add(1, 'days').endOf('day').toDate()

        $scope.signatories = organizationFactory.getSignatories({organizationId: $rootScope.user.organization_id})
        prom = agreementTaskFactory.getForOffer({offerId: offer.id}).$promise
        prom.then(
          (data) ->
            $scope.task = data
            $scope.addAgreement = 'true'
            return
          (data, status) ->
            $scope.newTask = true
            $scope.task =
              offer: offer.id
              body: ''
            return
        )

        $scope.addSignatory = ->
          $scope.signatorySuccess = false
          $scope.signatoryError = false

          if $scope.addSignatoryForm.$valid
            promise = organizationFactory.saveSignatory({organizationId: $rootScope.user.organization_id}, $scope.signatory).$promise

            promise.then(
              (data) ->
                $scope.signatorySuccess = true
                $scope.signatories = organizationFactory.getSignatories({organizationId: $rootScope.user.organization_id})
                $scope.signatory = null
                $scope.addSignatoryForm.$setPristine()
                return

              (data, status) ->
                $scope.signatoryError = true
                return
            )
          else
            UtilsService.setDirtyFields($scope.addSignatoryForm)
            $scope.addSignatoryForm.submitted = true
          return

        $scope.getSignatoryDisplay = (signatory) ->
          signatory.first_name + " " + signatory.last_name + " - " + signatory.position

        $scope.submit = ->
          if $scope.addAgreement == 'false'
            goToNextStep(offer.id, 5)
            return

          if $scope.form.$valid && $scope.signatoryForm.$valid
            acceptedFields = ['body', 'offer']
            if !$scope.newTask
              promise = agreementTaskFactory.update({}, _.pick($scope.task, acceptedFields)).$promise
            else
              $scope.task.offer = offer.id
              promise = agreementTaskFactory.save({}, _.pick($scope.task, acceptedFields)).$promise

            promise.then(
              (data) ->
                goToNextStep(offer.id, 5)
                return

              (data, status) ->
                return
            )

            acceptedFields = ['agreement_stands_from', 'agreement_stands_to', 'agreement_signatories']
            $scope.offer.agreement_stands_from = moment($scope.offer.agreement_stands_from).format("YYYY-MM-DD")
            $scope.offer.agreement_stands_to = moment($scope.offer.agreement_stands_to).format("YYYY-MM-DD")
            promise = offerFactory.update({offerId: offer.id}, _.pick($scope.offer, acceptedFields)).$promise

            promise.then(
              (data) ->
                $scope.offerSuccess = true
                return

              (data, status) ->
                $scope.offerError = true
                return
            )

            return
          else
            UtilsService.setDirtyFields($scope.form)
            $scope.form.submitted = true

            UtilsService.setDirtyFields($scope.signatoryForm)
            $scope.signatoryForm.submitted = true
          return

      when 5
        $scope.is_edited = true
        $scope.isActiveOffer = moment(offer.publish_to) > moment()

        begin_date = new moment(offer.publish_from)
        end_date = new moment(offer.publish_to)
        now = new moment()

        diff_now = end_date - now
        diff_begin = end_date - begin_date

        if diff_now < 0
          diff_now = 0

        volunteers_accepted = offer.volunteers_joined_count
        volunteers_left = if offer.volunteers_joined_count < offer.volunteer_max_count then offer.volunteer_max_count - offer.volunteers_joined_count else 0

        $scope.timeChartData = [
          {
            value: diff_now/diff_begin,
            color: "#91004b"
          },
          {
            value: 1 - (diff_now/diff_begin),
            color: "#E2EAE9"
          }
        ]
        $scope.volunteersChartData = [
          {
            value: volunteers_accepted,
            color: "#044c83"
          },
          {
            value: volunteers_left,
            color: "#E2EAE9"
          }
        ]
        state = StateService.getOfferStates()

        $scope.save = ->
          if $scope.offer.status == state.published
            $scope.offer.status = state.published_edited
          else
            $scope.offer.status = state.published

          promise = offerFactory.update({offerId: $scope.offer.id}, {status: $scope.offer.status}).$promise

          promise.then(
            (offer) ->
              console.log offer
              $state.go('offer.details', {id: offer.id})
            ,
            (errors) ->
              console.log errors
              return
          )
          return

      else
        $state.go('offer.list')

    return
])
