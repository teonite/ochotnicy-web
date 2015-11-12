# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller "AgreementModalCtrl", [
  "$scope", "$modalInstance", "$state",
  "UtilsService",
  "agreementFactory", "certificateFactory",
  "volunteerId", "offerId", "type",
  ($scope, $modalInstance, $state,
   UtilsService,
   agreementFactory, certificateFactory,
   volunteerId, offerId, type) ->
    $scope.is_proceeded = true
    $scope.success = false
    $scope.fail = false
    $scope.tasks = false
    $scope.time = false
    $scope.offerFields = false
    $scope.offerPublished = false
    $scope.offerId = offerId
    $scope.agreementLink = undefined

    switch type
      when 'certificate'
        $scope.displayName = "certyfikatu"
        factory = certificateFactory
      else
        $scope.displayName = "umowy"
        factory = agreementFactory
    if not volunteerId.length
      volunteerId = [volunteerId]
    promise = factory.bulk({}, {volunteers: volunteerId, offer: offerId}).$promise
    promise.then(
      (data) ->
        $scope.success = true
        $scope.is_proceeded = false
        console.log data
        $scope.agreementLink = data.filename
        return
      (error) ->
        $scope.is_proceeded = false
        switch error.status
          when 403
            switch error.data.detail.toLowerCase()
              when "offer has not ended yet" then $scope.time = true
              when "fill all required fields in offer" then $scope.offerFields = true
              when "offer not published" then $scope.offerPublished = true
              when "you already created an agreement", "you already created an certificate"
                $scope.is_proceeded = true
                promise = factory.get({volunteerId: volunteerId, offerId: offerId}).$promise
                promise.then(
                  (data) ->
                    $scope.success = true
                    $scope.is_proceeded = false
                    $scope.agreementLink = data.not_signed_resource
                    return
                  (error) ->
                    $scope.fail = true
                    $scope.is_proceeded = false
                    return
                )
              else $scope.fail = true
          when 404
            switch error.data.detail.toLowerCase()
              when "couldn't find any tasks assigned to this agreement" then $scope.tasks = true
              else $scope.fail = true

        return
    )

    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
      return

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.goToOfferDetails = ->
      $state.go "offer.agreement.details", {id: offerId}
      $modalInstance.dismiss "cancel"
      return

    return
]
