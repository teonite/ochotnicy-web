# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "organizationAbilityFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/organization-abilities/:id/?",
      {}
    ,

      update:
        url: Config.apiRoot + "/organization-abilities/:id/?"
        method: "PATCH"
        params:
          id: '@id'
    )
]
