# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "certificateTemplateFactory", [
  "$resource"
  "Config"
  ($resource, Config) ->
    return $resource(Config.apiRoot + "/certificate-templates/?",
      {}
    ,

      update:
        method: "PATCH"

      getGlobal:
        url: Config.apiRoot + "/admin/certificate-templates/?"
        method: "GET"

      updateGlobal:
        url: Config.apiRoot + "/admin/certificate-templates/?"
        method: "PATCH"
    )
]
