# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "certificateFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/certificates/offer/:offerId/volunteer/:volunteerId/?",
      {}
    ,

      update:
        method: "PATCH"

      bulk:
        url: Config.apiRoot + "/certificates/?"
        method: "POST"
    )
]
