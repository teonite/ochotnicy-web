# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("AdminOrganizationsCtrl", [
  "$scope", "$rootScope", "$window",
  "UtilsService", "Config",
  "organizationFactory",
  "organizations"
  ($scope, $rootScope, $window,
   UtilsService, Config,
   organizationFactory,
   organizations) ->
    $rootScope.hideBanner = true
    $scope.organizations = organizations

    $scope.orderingOptions = [
      {name: 'Alfabetycznie - rosnąco', field: 'fullname'},
      {name: 'Alfabetycznie - malejąco', field: '-fullname'},
      {name: 'Najmniej ofert', field: 'count'},
      {name: 'Najwięcej ofert', field: '-count'}
    ]
    $scope.ordering = $scope.orderingOptions[0]

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    applyCounts = (organization) ->
        counts = organizationFactory.getOffersCount({organizationId: organization.id}).$promise
        counts.then(
          (data) ->
            console.log data
            organization.in_review = data['in_review']
            organization.rejected = data['unpublished'] + data['rejected']
            organization.published = data['published'] + data['published_edited']
            organization.draft = data['draft']
            organization.count = _.reduce(['in_review', 'unpublished', 'rejected', 'published', 'published_edited', 'draft'], ((memo, obj) -> memo + parseInt(data[obj])), 0);
          ->
            organization.inReview = 0
            organization.rejected = 0
            organization.published = 0
            organization.draft = 0
            organization.count = 0
        )
        return

    for organization in $scope.organizations
      applyCounts(organization)

    update = ->
      organizationFactory.query().$promise.then(
        (data) ->
          $scope.organizations = data
          for organization in $scope.organizations
            applyCounts(organization)
          return

        (data, status) ->
          console.log data
          return
      )
      return

    $scope.changeAutoskip = (organization) ->
      organization.can_autoskip = !organization.can_autoskip
      acceptedFields = ['can_autoskip']
      promise = organizationFactory.update({organizationId: organization.id}, _.pick(organization, acceptedFields)).$promise

      promise.then(
        (data) ->
          $window.alert 'Zmiana udana'
          update()
          return

        (data, status) ->
          $window.alert 'Zmiana nieudana'
          update()
          return
      )

      return

    return
])
