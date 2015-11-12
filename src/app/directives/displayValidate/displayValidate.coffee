angular.module("wolontariat.directives").directive "displayValidate", [
  ->
    return (
      restrict: "AE"
      scope:
        element: "="
        model: "="
        required: "="
        edit: "="
      replace: true
      templateUrl: "displayValidate/displayValidate.html"
      link: (scope) ->
        if scope.model?
          if !angular.isString(scope.model)
            scope.modelCopy = angular.copy(scope.model).toString()
          else
            scope.modelCopy = angular.copy(scope.model)
        else
          scope.modelCopy = ''
    )
]