# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "agreementTemplateFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/agreement-templates/?",
      {}
    ,

      update:
        method: "PATCH"

      getGlobal:
        url: Config.apiRoot + "/admin/agreement-templates/?"
        method: "GET"

      updateGlobal:
        url: Config.apiRoot + "/admin/agreement-templates/?"
        method: "PATCH"
    )
]
