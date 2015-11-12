#
# Portal Ochotnicy - http://ochotnicy.pl
#
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
#
# Development: TEONITE - http://teonite.com
#
angular.module("wolontariat.filters").filter "htmlToPlaintext", [->
  (text) ->
    String(text).replace /<[^>]+>/gm, ''
]
