# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "categoryFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/categories/?",{})
]
