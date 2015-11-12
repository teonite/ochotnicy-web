# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("VolunteerApplicationsCtrl", [
  "$scope", "$rootScope", "$state", "$filter", "$modal", "$window",
  "UtilsService",
  "organizationAbilityFactory", "agreementFactory", "offerFactory", "certificateFactory", "volunteerFactory",
  "profile", "applications", "promotedOffers", "agreements", "certificates",
  ($scope, $rootScope, $state, $filter, $modal, $window,
   UtilsService,
   organizationAbilityFactory, agreementFactory, offerFactory, certificateFactory, volunteerFactory,
   profile, applications, promotedOffers, agreements, certificates) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    if !$rootScope.user.is_volunteer
      $state.go("offer.list")

    $scope.volunteer = profile
    $scope.promotedOffers = promotedOffers
    $scope.applications = applications
    agreementOffers = []

    _.map agreements, (element) ->
      agreementOffers.push element.offer
      return

    updateApplications = ->
      volunteerFactory.getApplications({id: profile.id}).$promise.then(
        ((data) ->
          applications = data
          $scope.pendingApplications = $filter('filter')(applications,
            (application) ->
              application.status == 0
          )
          $scope.acceptedApplications = $filter('filter')(applications,
            (application) ->
              application.status == 1 and application.offer.id not in agreementOffers
          )
          $scope.rejectedApplications = $filter('filter')(applications,
            (application) ->
              application.status == 2
          )
          $scope.archiveApplications = $filter('filter')(applications,
            (application) ->
              application.offer.id in agreementOffers
          )

          certOffer = []
          for certificate in certificates
            certOffer.push certificate.offer

          for application in $scope.archiveApplications
            application.has_certificate = false

            console.log application
            if application.offer.id in certOffer
              application.has_certificate = true

            updateRatings(application)
          return
        ),
        (error) ->
          return
      )
      return

    updateApplications()

    updateRatings = (application) ->
      offerFactory.getRatings({offerId: application.offer.id}).$promise.then(
        (data) ->
          application.offer.testimonial =
            organization: null
            volunteer: null

          for rating in data.organization
            if rating.created_by == profile.user_id
              application.offer.testimonial.organization = rating
              break
          for rating in data.volunteer
            if rating.volunteer == profile.id
              application.offer.testimonial.volunteer = rating
              break
          return
        (error) ->
          application.offer.testimonial =
            organization: null
            volunteer: null
          return
      )
      return

    $scope.getAgreement = (offerId, type) ->
      switch type
        when 'certificate' then factory = certificateFactory
        else factory = agreementFactory

      promise = factory.get({volunteerId: profile.id, offerId: offerId}).$promise
      promise.then(
        (data) ->
          $window.location = UtilsService.getMediaUrl("/media/" + data.not_signed_resource, '')
          return
        (error) ->
          return
      )

    $scope.openRatingModal = (organization, offer) ->
      modalInstance = $modal.open(
        templateUrl: "organizationRatingModal.html"
        controller: "OrganizationRatingModalCtrl"
        windowTemplateUrl: "modalWindowBright.html"
        backdrop: "static"
        resolve:
          offer: ->
            offer
          organization: ->
            organization
          abilities: ->
            organizationAbilityFactory.query().$promise
      )

      modalInstance.result.then (->
          updateApplications()
          return
        ), ->
          updateApplications()
          return
      return

    $scope.tab = "my"

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.setTab = (tab) ->
      if tab in ['my', 'archive', 'rejected']
        $scope.tab = tab
      return

    return
])
