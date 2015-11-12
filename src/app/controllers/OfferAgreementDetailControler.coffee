# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OfferAgreementDetailCtrl", [
  "$scope"
  "$rootScope"
  "$state"
  "Config"
  "UtilsService"
  "offerFactory"
  "agreementTaskFactory"
  "organizationFactory"
  "offer"
  "signatories"
  ($scope, $rootScope, $state, Config, UtilsService, offerFactory, agreementTaskFactory, organizationFactory, offer, signatories) ->
    $scope.newTask = false

    $scope.taskSuccess = false
    $scope.taskError = false
    $scope.signatorySuccess = false
    $scope.signatoryError = false
    $scope.offerSuccess = false
    $scope.offerError = false

    $scope.opened =
      pub: false
      close: false

    $scope.dateOptions =
      startingDay: 1

    $scope.pubMinDate = moment(offer.publish_from).startOf('day').toDate()
    $scope.closeMinDate = moment(offer.publish_from).add(1, 'days').endOf('day').toDate()

    $rootScope.smallBanner = true
    $rootScope.hideBanner = false
    $scope.tinymceOptions = Config.tinymceOptions

    if !$rootScope.user.is_organization
      $state.go("offer.list")

    $scope.offer = offer
    prom = agreementTaskFactory.getForOffer({offerId: offer.id}).$promise
    prom.then(
      (data) ->
        $scope.task = data
        return
      (data, status) ->
        $scope.newTask = true
        $scope.task =
          offer: offer.id
          body: ''
        return
    )
    $scope.signatories = signatories

    $scope.openCalendar = ($event, type) ->
      $event.preventDefault()
      $event.stopPropagation()

      switch type
        when 'close' then $scope.opened.close = true
        when 'pub' then $scope.opened.pub = true

      return

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

    $scope.doTheBack = ->
      window.history.back()

    $scope.submit = ->
      if $scope.form.$valid && $scope.signatoryForm.$valid
        $scope.taskSuccess = false
        $scope.taskError = false
        $scope.offerSuccess = false
        $scope.offerError = false

        acceptedFields = ['body', 'offer']
        if !$scope.newTask
          promise = agreementTaskFactory.update({}, _.pick($scope.task, acceptedFields)).$promise
        else
          $scope.task.offer = offer.id
          promise = agreementTaskFactory.save({}, _.pick($scope.task, acceptedFields)).$promise

        promise.then(
          (data) ->
            $scope.taskSuccess = true
            return

          (data, status) ->
            $scope.taskError = true
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
      else
        UtilsService.setDirtyFields($scope.form)
        $scope.form.submitted = true

        UtilsService.setDirtyFields($scope.signatoryForm)
        $scope.signatoryForm.submitted = true

      return

    return
])
