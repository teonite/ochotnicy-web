angular.module("wolontariat.directives").directive 'dateLower', [
  '$filter'
  'UtilsService'
  ($filter, UtilsService) ->
    {
      require: 'ngModel'
      link: (scope, elm, attrs, ctrl) ->

        validateDateRange = (inputValue) ->
          fromDate = inputValue
          toDate = attrs.dateLower
          isValid = UtilsService.isValidDateRange(fromDate, toDate)
          if !ctrl.$isEmpty(inputValue)
            ctrl.$setValidity 'dateLower', isValid
          inputValue

        ctrl.$parsers.unshift validateDateRange
        ctrl.$formatters.push validateDateRange
        attrs.$observe 'dateLower', ->
          validateDateRange ctrl.$viewValue
          return
        return

    }
]

