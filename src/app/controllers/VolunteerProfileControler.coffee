# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("VolunteerProfileCtrl", [
  "$scope", "$rootScope", "$filter", "$modal", "$window"
  "UtilsService", "geocoderFactory",
  "organizationAbilityFactory", "agreementFactory", "offerFactory", "certificateFactory", "volunteerFactory",
  "profile", "applications", "promotedOffers", "agreements", "certificates", "evaluations",
  ($scope, $rootScope, $filter, $modal, $window,
   UtilsService, geocoderFactory,
   organizationAbilityFactory, agreementFactory, offerFactory, certificateFactory, volunteerFactory
   profile, applications, promotedOffers, agreements, certificates, evaluations) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.volunteer = profile
    $scope.promotedOffers = promotedOffers
    $scope.applications = applications
    $scope.isSelfProfile = false

    $scope.volunteerRatings = evaluations[-2..]

    $scope.user = $rootScope.user

    $scope.doTheBack = ->
      window.history.back()

    if $rootScope.user? && profile.id == $rootScope.user.volunteer_id
      $scope.isSelfProfile = true

    if $scope.isSelfProfile || $scope.user.is_superuser
      agreementOffers = []
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

      $scope.tab = "my"
      $scope.setTab = (tab) ->
        if tab in ['my', 'archive', 'rejected']
          $scope.tab = tab
        return

    else
      $scope.tab = "actual"
      $scope.setTab = (tab) ->
        if tab in ['actual', 'archive']
          $scope.tab = tab
        return

      now = moment()
      $scope.archiveApplications = $filter('filter')(applications,
        (application) ->
          application.status == 1 and moment(application.offer.agreement_stands_to).diff(now) < 0
      )

      $scope.actualApplications = $filter('filter')(applications,
        (application) ->
          application.status == 1 and (moment(application.offer.agreement_stands_to).diff(now) > 0 or application.offer.agreement_stands_to == null)
      )

    $scope.isOrganizationOrSelf = ->
      $scope.isSelfProfile or ($rootScope.user? and $rootScope.user.is_organization)


    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.constructAddress = ->
      str = profile.street + ' ' + profile.house_number
      if profile.apartment_number? and profile.apartment_number.length
        str += '/' + profile.apartment_number
      str += ", " + profile.zipcode + ' ' + profile.city

      if str.length < 5
        return "Brak danych"

      return str

    $scope.mapLatLng = {}
    $scope.mapOptions =
      disableDefaultUI: true

    $scope.$watch 'mapLatLng', ->
      $scope.latLength = _.size($scope.mapLatLng);

    geocoderFactory.latLngForAddress($scope.constructAddress()).then(
      (data) ->
        $scope.mapLatLng = data
        $scope.markerPos = angular.copy(data)
    )

    return
])
