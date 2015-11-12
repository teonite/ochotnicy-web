angular.module("wolontariat.directives").directive "loader", [
  "Config"
  "$filter"
  "UtilsService"
  (Config, $filter, UtilsService) ->
    return (
      restrict: "A"
      scope:
        showText: "="
        loaderStyle: "="
      replace: true
      templateUrl: "loader/loader.html"
      link: (scope) ->
        console.log scope
    )
]