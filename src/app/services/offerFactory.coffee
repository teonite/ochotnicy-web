# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "offerFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/offers/:offerId/?",
      {}
    ,
      update:
        method: "PATCH"

      getOffersWithCategories:
        url: Config.apiRoot + "/offers/?category=:categories"
        method: "GET"
        isArray: true
        params:
          categories: "@category"

      getPromotedOffers:
        url: Config.apiRoot + "/promoted-offers/?"
        method: "GET"
        isArray: true

      apply:
        url: Config.apiRoot + "/offers/:offerId/applications/?"
        method: "POST"
        params:
          offerId: "@offerId"

      getApplicationsCount:
        url: Config.apiRoot + "/offers/:offerId/applications/count/?"
        method: "GET"
        params:
          offerId: "@offerId"

      getApplications:
        url: Config.apiRoot + "/offers/:offerId/applications/:status/?"
        method: "GET"
        isArray: true
        params:
          offerId: "@offerId"
          status: "@status"

      checkApplication:
        url: Config.apiRoot + "/offers/:offerId/applications/check/?"
        method: "GET"
        params:
          offerId: "@offerId"

      search:
        url: Config.apiRoot + "/offers/search/:phrase/?"
        method: "POST"
        isArray: true
        params:
          phrase: "@phrase"

      getAgreementTemplate:
        url: Config.apiRoot + "/offers/:offerId/agreement-template/?"
        method: "GET"
        params:
          offerId: "@offerId"

      getAgreements:
        url: Config.apiRoot + "/offers/:offerId/agreements/?"
        method: "GET"
        isArray: true
        params:
          offerId: "@offerId"

      getCertificateTemplate:
        url: Config.apiRoot + "/offers/:offerId/certificate-template/?"
        method: "GET"
        params:
          offerId: "@offerId"

      getCertificates:
        url: Config.apiRoot + "/offers/:offerId/certificates/?"
        method: "GET"
        isArray: true
        params:
          offerId: "@offerId"

      getRatings:
        url: Config.apiRoot + "/offers/:offerId/ratings/?"
        method: "GET"
        params:
          offerId: "@offerId"

      getAdminList:
        url: Config.apiRoot + "/admin-offers/?"
        method: "GET"
        isArray: true
    )
]
