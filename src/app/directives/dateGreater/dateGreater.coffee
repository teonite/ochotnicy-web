angular.module("wolontariat.directives").directive 'dateGreater', [
  '$filter'
  'UtilsService'
  ($filter, UtilsService) ->
    {
      require: 'ngModel'
      link: (scope, elm, attrs, ctrl) ->

        validateDateRange = (inputValue) ->
          fromDate = attrs.dateGreater
          toDate = inputValue
          isValid = UtilsService.isValidDateRange(fromDate, toDate)
          if !ctrl.$isEmpty(inputValue)
            ctrl.$setValidity 'dateGreater', isValid
          inputValue

        ctrl.$parsers.unshift validateDateRange
        ctrl.$formatters.push validateDateRange
        attrs.$observe 'dateGreater', ->
          validateDateRange ctrl.$viewValue
          return
        return

    }
]