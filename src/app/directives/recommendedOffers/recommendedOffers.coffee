angular.module("wolontariat.directives").directive "recommendedOffers", [
  "Config"
  "$filter"
  "UtilsService"
  (Config, $filter, UtilsService) ->
    return (
      restrict: "A"
      scope:
        offers: "="
        limit: "="
      replace: true
      templateUrl: "recommendedOffers/recommendedOffers.html"
      link: (scope) ->
        scope.getMediaUrl = (mediaUrl, type) ->
          UtilsService.getMediaUrl(mediaUrl, type)
    )
]