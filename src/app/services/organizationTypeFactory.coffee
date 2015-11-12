# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "organizationTypeFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/organization-types/:typeId/?",
      {}
    ,
      saveType:
        url: Config.apiRoot + "/organization-types/?"
        method: "POST"

      updateType:
        url: Config.apiRoot + "/organization-types/:typeId/?"
        method: "PUT"
        params:
          abilityId: '@id'
    )
]
