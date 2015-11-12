# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OfferDetailsCtrl", [
  "$scope", "$rootScope", "$state", "$modal", "$location",
  "UtilsService", "Config", "geocoderFactory",
  "offerFactory", "agreementFactory", "volunteerFactory",
  "offer", "promotedOffers", "userApplication", "fbAppId",
  ($scope, $rootScope, $state, $modal, $location, UtilsService, Config, geocoderFactory, offerFactory, agreementFactory, volunteerFactory, offer, promotedOffers, userApplication, fbAppId) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.is_edited = false
    $scope.chartOptions =
      percentageInnerCutout: 70
      showScale: false
      showTooltips: false

    $scope.user = $rootScope.user
    $scope.offer = offer
    $scope.promotedOffers = promotedOffers
    $scope.userApplication = userApplication.application
    $scope.isActiveOffer = moment(offer.publish_to) > moment()

    $scope.isPublishingOrganization = false
    $scope.shareUrl = encodeURI($location.absUrl())
    $scope.fbAppId = fbAppId.value

    if $rootScope.user? && offer.publishing_organization.id == $rootScope.user.organization_id
      $scope.isPublishingOrganization = true
      $scope.selectedTab = 'volunteer'

      $scope.orderingOptions =
        applications: [
          {name: 'Alfabetycznie - rosnąco', field: 'volunteer.last_name'},
          {name: 'Alfabetycznie - malejąco', field: '-volunteer.last_name'},
          {name: 'Data aplikacji - rosnąco', field: 'created_at'},
          {name: 'Data aplikacji - malejąco', field: '-created_at'},
        ]
        agreements: [
          {name: 'Alfabetycznie - rosnąco', field: 'volunteer.last_name'},
          {name: 'Alfabetycznie - malejąco', field: '-volunteer.last_name'},
          {name: 'Data zawarcia umowy - rosnąco', field: 'agreement.created_at'},
          {name: 'Data zawarcia umowy - malejąco', field: '-agreement.created_at'},
        ]
        certificates: [
          {name: 'Alfabetycznie - rosnąco', field: 'volunteer.last_name'},
          {name: 'Alfabetycznie - malejąco', field: '-volunteer.last_name'},
          {name: 'Data wystawienia certyfikatu - rosnąco', field: 'certificate.created_at'},
          {name: 'Data wystawienia certyfikatu - malejąco', field: '-certificate.created_at'},
        ]
        ratings: [
          {name: 'Alfabetycznie - rosnąco', field: 'volunteer.last_name'},
          {name: 'Alfabetycznie - malejąco', field: '-volunteer.last_name'},
          {name: 'Najwyższa ocena', field: '-rating.organization.rating'},
          {name: 'Najniższa ocena', field: 'rating.organization.rating'}
        ]

      $scope.sorting =
        applications: $scope.orderingOptions.applications[0]
        agreements: $scope.orderingOptions.agreements[0]
        certificates: $scope.orderingOptions.certificates[0]
        ratings: $scope.orderingOptions.ratings[0]

      $scope.applications =
        certificate:
          have: []
          not: []
        agreement:
          have: []
          not: []
        ratings:
          have: []
          not: []

      $scope.checked =
        pending: []
        accepted: []
        agreementNew: []
        agreementExist: []
        certificateNew: []
        certificateExists: []
        reputationNew: []
        reputationExists: []


      update = ->
        $scope.finished =
          certificates: false
          agreements: false
          ratings: false

        $scope.certificate_volunteers = []
        $scope.agreement_volunteers = []
        $scope.rating_volunteers = []

        $scope.applications =
          certificate:
            have: []
            not: []
          agreement:
            have: []
            not: []
          ratings:
            have: []
            not: []

        console.log $scope.applications

        offerFactory.getCertificates({offerId: offer.id}).$promise.then(
          (data) ->
            $scope.certificates = {}
            for certificate in data
              $scope.certificate_volunteers.push certificate.volunteer
              $scope.certificates['Vol_' + certificate.volunteer] = certificate

            $scope.finished.certificates = true
            return
          (error) ->
            $scope.finished.certificates = true
            return
        )

        offerFactory.getAgreements({offerId: offer.id}).$promise.then(
          (data) ->
            $scope.agreements = {}
            for agreement in data
              $scope.agreement_volunteers.push agreement.volunteer
              $scope.agreements['Vol_' + agreement.volunteer] = agreement
            $scope.finished.agreements = true
          (error) ->
            $scope.finished.agreements = true
            return
        )

        offerFactory.getRatings({offerId: offer.id}).$promise.then(
          (data) ->
            console.log data
            $scope.ratings = {}
            for rating in data.volunteer
              if not $scope.ratings['Vol_' + rating.volunteer]?
                $scope.ratings['Vol_' + rating.volunteer] = {}

              $scope.rating_volunteers.push rating.volunteer
              $scope.ratings['Vol_' + rating.volunteer]['volunteer'] = rating

            for rating in data.organization
              if not $scope.ratings['Vol_' + rating.volunteer]?
                $scope.ratings['Vol_' + rating.volunteer] = {}
              $scope.ratings['Vol_' + rating.volunteer]['organization'] = {}
              $scope.ratings['Vol_' + rating.volunteer]['organization'] = rating

            $scope.finished.ratings = true
            return
          (error) ->
            $scope.finished.ratings = true
            return
        )

        $scope.finishWatch = $scope.$watch("finished", ->
          if $scope.finished.ratings and $scope.finished.agreements and $scope.finished.certificates
            for application in $scope.acceptedApplications

              application.has_agreement = application.volunteer.id in $scope.agreement_volunteers
              if application.has_agreement
                application.agreement = $scope.agreements['Vol_' + application.volunteer.id]
                $scope.applications.agreement.have.push application
              else
                $scope.applications.agreement.not.push application

              application.has_certificate = application.volunteer.id in $scope.certificate_volunteers
              if application.has_certificate
                application.certificate = $scope.certificates['Vol_' + application.volunteer.id]
                $scope.applications.certificate.have.push application
              else
                $scope.applications.certificate.not.push application

              application.has_rating = application.volunteer.id in $scope.rating_volunteers
              if application.has_rating
                application.rating = $scope.ratings['Vol_' + application.volunteer.id]
                $scope.applications.ratings.have.push application
              else
                $scope.applications.ratings.not.push application

            $scope.finishWatch()
          return
        true)

        return

      updateApplications = ->
        $scope.pendingApplications = offerFactory.getApplications({offerId: offer.id, status: 'pending'})
        offerFactory.getApplications({offerId: offer.id, status: 'accepted'}).$promise.then(
          (data) ->
            $scope.acceptedApplications = data
            update()
            return
          (err) ->
            return
        )
        $scope.rejectedApplications = offerFactory.getApplications({offerId: offer.id, status: 'rejected'})
        $scope.checked =
          pending: {}
          accepted: {}
          agreementNew: {}
          agreementExist: {}
          certificateNew: {}
          certificateExist: {}
          ratingNew: {}
          ratingExist: {}

        return

      updateApplications()

      $scope.checkSelectAll = (checklist, applications, type="vol") ->
        if not applications? then return false

        for application in applications
          id = application.volunteer.id
          if type != "vol"
            id = application.id

          if not checklist['Vol_' + id] then return false

        return true

      $scope.selectAll = (checklist, applications, type="vol") ->
        status = not $scope.checkSelectAll(checklist, applications, type)

        for application in applications
          id = application.volunteer.id
          if type != "vol"
            id = application.id
          checklist['Vol_' + id] = status
        console.log checklist
        return

      $scope.selectTab = (tab) ->
        switch tab
          when 'volunteer' then $scope.selectedTab = 'volunteer'
          when 'agreement' then $scope.selectedTab = 'agreement'
          when 'certificate' then $scope.selectedTab = 'certificate'
          when 'reputation' then $scope.selectedTab = 'reputation'
          else $scope.selectedTab = 'volunteer'

        return

      $scope.getIds = (applicationList, applications) ->
        ids = []
        for key, value of applicationList
          ids.push key.split('_')[1] if value
        return ids

      $scope.changeRatingStatus = (rating) ->
        rating.is_public = !rating.is_public
        acceptedFields = ['organization', 'offer', 'is_public']

        ratingsFactory.update({id: rating.id}, _.pick(rating, acceptedFields)).$promise.then(
          (data) ->
            update()
          (error) ->
            update()
        )
        return

      $scope.getAgreementModal = (volunteerId, type) ->
        modalInstance = $modal.open(
          templateUrl: "agreementModal.html"
          controller: "AgreementModalCtrl"
          resolve:
            offerId: ->
              offer.id
            volunteerId: ->
              volunteerId
            type: ->
              type
        )
        modalInstance.result.then (->
          updateApplications()
          return
        ), ->
          updateApplications()
          return

        return

      $scope.evaluateApplicationModal = (status, id) ->
        modalInstance = $modal.open(
          templateUrl: "evaluateApplicationModal.html"
          controller: "EvaluateApplicationModalCtrl"
          windowTemplateUrl: "modalWindowBright.html"
          backdrop: "static"
          resolve:
            status: ->
              status
            id: ->
              id
        )
        modalInstance.result.then ( ->
          updateApplications()
          return
        ), ->
          updateApplications()
          return

        return

      $scope.openRatingModal = (volunteer) ->
        modalInstance = $modal.open(
          templateUrl: "volunteerRatingModal.html"
          controller: "VolunteerRatingModalCtrl"
          windowTemplateUrl: "modalWindowBright.html"
          backdrop: "static"
          resolve:
            offer: ->
              $scope.offer
            volunteer: ->
              volunteer
            abilities: ->
              volunteerFactory.getAllAbilities({id: volunteer.id}).$promise
        )

        modalInstance.result.then (->
          updateApplications()
          return
        ), ->
          updateApplications()
          return

        return

    $scope.openApplicationModal = (size) ->
      modalInstance = $modal.open(
        templateUrl: "applicationModal.html"
        controller: "ApplicationModalCtrl"
        size: size
        backdrop: "static"
        resolve:
          offer: ->
            $scope.offer
      )
      modalInstance.result.then ( ->
        prom = offerFactory.checkApplication({offerId: offer.id}).$promise
        prom.then(
          (data) ->
            $scope.userApplication = data.application
            return
          (err) ->
            return
        )
        return
      ), ->
        prom = offerFactory.checkApplication({offerId: offer.id}).$promise
        prom.then(
          (data) ->
            $scope.userApplication = data.application
            return
          (err) ->
            return
        )
        return

      return

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    $scope.apply = ->
      unless $scope.user
        $state.go "login"
      if !$scope.user.is_volunteer || userApplication.application
        return
      $scope.openApplicationModal()
      return

    $scope.mapLatLng = {}
    $scope.mapOptions =
      disableDefaultUI: true

    $scope.$watch 'mapLatLng', ->
      $scope.latLength = _.size($scope.mapLatLng);

    geocoderFactory.latLngForAddress(offer.localization).then(
      (data) ->
        $scope.mapLatLng = data
        $scope.markerPos = angular.copy(data)
    )

    $scope.doTheBack = ->
      window.history.back()

    $scope.$on("$viewContentLoaded", () ->
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
      return
    )

    return
])
