# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("OrganizationRatingListCtrl", [
  "$scope", "$rootScope", "$filter", "$modal", "$window"
  "UtilsService",
  "ratingsFactory", "organizationFactory",
  "organization", "ratings", "promotedOffers",
  ($scope, $rootScope, $filter, $modal, $window,
   UtilsService,
   ratingsFactory, organizationFactory,
   organization, ratings, promotedOffers) ->
    $rootScope.smallBanner = true
    $rootScope.hideBanner = false

    $scope.organization = organization
    $scope.promotedOffers = promotedOffers
    $scope.ratings = ratings
    $scope.isSelfProfile = false

    $scope.orderingOptions = [
      {name: 'Alfabetycznie - rosnąco', field: 'volunteer_last_name'},
      {name: 'Alfabetycznie - malejąco', field: '-volunteer_last_name'},
      {name: 'Najwyższa ocena', field: '-rating'},
      {name: 'Najniższa ocena', field: 'rating'}
    ]
    $scope.ordering = $scope.orderingOptions[0]

    if $rootScope.user? && organization.id == $rootScope.user.organization_id
      $scope.isSelfProfile = true

      $scope.publicRatings = $filter('filter')(ratings,
        (rating) ->
          rating.is_public == null || rating.is_public == true
      )

      $scope.privateRatings = $filter('filter')(ratings,
        (rating) ->
          rating.is_public == false
      )

      update = ->
        ratings = organizationFactory.getRatings({organizationId: organization.id}).$promise.then(
          (data) ->
            ratings = data
            $scope.publicRatings = $filter('filter')(data,
              (rating) ->
                rating.is_public == null || rating.is_public == true
            )

            $scope.privateRatings = $filter('filter')(data,
              (rating) ->
                rating.is_public == false
            )
            return
          (error) ->
            return
        )
        return

      $scope.changeStatus = (rating) ->
        rating.is_public = !rating.is_public
        acceptedFields = ['organization', 'offer', 'is_public']

        ratingsFactory.update({id: rating.id}, _.pick(rating, acceptedFields)).$promise.then(
          (data) ->
            update()
          (error) ->
            update()
        )
        return

    else
      _.map ratings, (element) ->
        if element.is_public is null
          element.testimonial = "Brak opisu"
        if element.is_public isnt null and not element.is_public
          element.testimonial = "Opis jest prywatny"
        return
      $scope.publicRatings = ratings

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    return
])
