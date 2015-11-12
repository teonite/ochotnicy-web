# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "organizationFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/organizations/:organizationId/?",
      {}
    ,
      update:
        method: "PATCH"

      getOffers:
        url: Config.apiRoot + "/organizations/:organizationId/offers/?status=:statusList"
        method: "GET"
        isArray: true
        params:
          organizationId: "@organizationId"
          statusList: "@status"

      getOffersCount:
        url: Config.apiRoot + "/organizations/:organizationId/offers/count/?"
        method: "GET"
        params:
          organizationId: "@organizationId"

      getAgreementTemplate:
        url: Config.apiRoot + "/organizations/:organizationId/agreement-template/?"
        method: "GET"
        params:
          organizationId: "@organizationId"

      getCertificateTemplate:
        url: Config.apiRoot + "/organizations/:organizationId/certificate-template/?"
        method: "GET"
        params:
          organizationId: "@organizationId"

      getSignatories:
        url: Config.apiRoot + "/organizations/:organizationId/signatories/?"
        method: "GET"
        isArray: true
        params:
          organizationId: "@organizationId"

      saveSignatory:
        url: Config.apiRoot + "/organizations/:organizationId/signatories/?"
        method: "POST"
        params:
          organizationId: "@organizationId"

      getRatings:
        url: Config.apiRoot + "/organizations/:organizationId/ratings/?"
        method: "GET"
        isArray: true
        params:
          organizationId: "@organizationId"
    )
]
