# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "abilityFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/abilities/:abilityId/?",
      {}
    ,

      update:
        url: Config.apiRoot + "/abilities/:abilityId/?"
        method: "PATCH"
        params:
          abilityId: '@id'
    )
]
