angular.module("wolontariat.directives").directive "wizardHeader", [
  "Config"
  "$filter"
  "UtilsService"
  (Config, $filter, UtilsService) ->
    return (
      restrict: "A"
      scope:
        step: "="
      templateUrl: (elem,attrs) ->
        attrs.url
    )
]