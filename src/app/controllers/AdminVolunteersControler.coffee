# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("AdminVolunteersCtrl", [
  "$scope", "$rootScope",
  "UtilsService", "Config",
  "volunteerFactory",
  "volunteers"
  ($scope, $rootScope,
   UtilsService, Config,
   volunteerFactory,
   volunteers) ->
    $rootScope.hideBanner = true

    $scope.volunteers = volunteers

    $scope.orderingOptions = [
      {name: 'Alfabetycznie - rosnąco', field: 'last_name'},
      {name: 'Alfabetycznie - malejąco', field: '-last_name'},
      {name: 'Najmniej aplikacji', field: 'count'},
      {name: 'Najwięcej aplikacji', field: '-count'}
    ]
    $scope.ordering = $scope.orderingOptions[0]

    $scope.getMediaUrl = (mediaUrl, type) ->
      UtilsService.getMediaUrl(mediaUrl, type)

    applyCounts = (volunteer) ->
        counts = volunteerFactory.getApplicationsCount({id: volunteer.id}).$promise
        counts.then(
          (data) ->
            console.log data
            volunteer.acceptedVolunteers = data['accepted']
            volunteer.waitingVolunteers = data['pending to review']
            volunteer.rejectedVolunteers = data['rejected']
            volunteer.count = data['accepted'] + data['pending to review'] + data['rejected']
          ->
            volunteer.acceptedVolunteers = 0
            volunteer.waitingVolunteers = 0
            volunteer.rejectedVolunteers = 0
            volunteer.count = 0
        )
        return

    for volunteer in $scope.volunteers
      applyCounts(volunteer)

    return
])
