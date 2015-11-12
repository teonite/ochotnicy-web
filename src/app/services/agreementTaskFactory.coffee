# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "agreementTaskFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/agreement-tasks/?",
      {}
    ,

      update:
        method: "PATCH"

      getForOffer:
        url: Config.apiRoot + "/agreement-tasks/offer/:offerId/?"
        method: "GET"
        params:
          offerId: "@offerId"

      getForOfferVolunteer:
        url: Config.apiRoot + "/agreement-tasks/offer/:offerId/volunteer/:volunteerId/?"
        method: "GET"
        params:
          offerId: "@offerId"
          volunteerId: "@volunteerId"

    )
]
