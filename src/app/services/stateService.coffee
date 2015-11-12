# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").factory "StateService", [
  "$resource"
  "Config"
  ($resource, Config) ->
    getOfferStates: ->
      DRAFT = 0
      IN_REVIEW = 1
      PUBLISHED = 2
      PUBLISHED_EDITED = 3
      DEPUBLISHED = 4
      REJECTED = 5
      REMOVED = 6

      ret =
        draft: DRAFT
        in_review: IN_REVIEW
        published: PUBLISHED
        published_edited: PUBLISHED_EDITED
        unpublished: DEPUBLISHED
        rejected: REJECTED
        removed: REMOVED

      return ret

    getProofTypes: ->
      IDENTITY_CARD = 0
      SCHOOL_CARD = 1
      HIGHSCHOOL_CARD = 2
      PASSPORT = 3

      return [
        {id: IDENTITY_CARD, name: 'dowód osobisty'},
        {id: SCHOOL_CARD, name: 'legitymacja szkolna'},
        {id: HIGHSCHOOL_CARD, name: 'legitymacja studencka'},
        {id: PASSPORT, name: 'paszport'}
      ]
]