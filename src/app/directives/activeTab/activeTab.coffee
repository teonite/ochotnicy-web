angular.module("wolontariat.directives").directive "activeTab", [
  "$location"
  ($location) ->
    return (
      restrict: "A"
      scope: true
      link: (scope, element, attr) ->
        scope.$on "$routeChangeSuccess", (event, current, previous) ->

          #            console.log($location.path());
          pathLevel = attr.activeTab or 1
          pathToCheck = $location.path().split("/")[pathLevel] or "current $location.path doesn't reach this level"
          tabLink = undefined

          # Above, we use the logical 'or' operator to provide a default value
          # in cases where 'undefined' would otherwise be returned.
          # This prevents cases where undefined===undefined,
          # possibly causing multiple tabs to be 'active'.
          if attr.href
            tabLink = attr.href.split("/")[pathLevel] or "href doesn't include this level"
          else if attr.root
            tabLink = attr.root.split("/")[pathLevel] or "href doesn't include this level"
          else
            return

          # now compare the two:
          if pathToCheck is tabLink
            element.parent().addClass "active"
          else
            element.parent().removeClass "active"
          return

        return
    )
]
