# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.services").factory "socialFactory", [
  "Config"
  (Config) ->
    return (name) ->
      Config.backendRoot + '/accounts/' + name + '/login/?'
]
