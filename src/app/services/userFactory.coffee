# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "userFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/users/:userId/?",
      {}
    ,
      update:
        method: "PATCH"

      activate:
        url: Config.apiRoot + "/users/activate/:hash/?"
        method: "GET"
        params:
          hash: '@id'

      logout:
        url: Config.apiRoot + "/users/logout/?"
        method: "GET"
    )
]
