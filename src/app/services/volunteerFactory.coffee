# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "volunteerFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/volunteers/:id/?",
      {}
    ,
      update:
        method: "PATCH"

      getApplications:
        url: Config.apiRoot + "/volunteers/:id/applications/?status=:statusList"
        method: "GET"
        isArray: true
        params:
          statusList: "@status"
          id: "@id"

      getApplicationsCount:
        url: Config.apiRoot + "/volunteers/:id/applications/count/?"
        method: "GET"
        params:
          id: "@id"

      getAgreements:
        url: Config.apiRoot + "/volunteers/:id/agreements/?"
        method: "GET"
        isArray: true
        params:
          id: "@id"

      getCertificates:
        url: Config.apiRoot + "/volunteers/:id/certificates/?"
        method: "GET"
        isArray: true
        params:
          id: "@id"

      getAllAbilities:
        url: Config.apiRoot + "/volunteers/:id/abilities/?"
        method: "GET"
        isArray: true
        params:
          id: "@id"

      getRatings:
        url: Config.apiRoot + "/volunteers/:id/ratings/?"
        isArray: true
        method: "GET"
        params:
          id: "@id"
    )
]
