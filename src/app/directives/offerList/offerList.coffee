angular.module("wolontariat.directives").directive "offerList", [
  "$filter", "$location", "$anchorScroll",
  "UtilsService", "StateService",
  ($filter, $location, $anchorScroll, UtilsService, StateService) ->
    return (
      restrict: "A"
      scope:
        offers: "="
        limit: "="
        options: "="
      replace: false
      templateUrl: (elem, attr) ->
        if attr.type?
          'offerList/'+attr.type+'.html'
        else
          'offerList/default.html'

      link: (scope) ->
        scope.chartOptions =
          percentageInnerCutout: 90
          showScale: false
          showTooltips: false

        scope.getMediaUrl = (mediaUrl, type) ->
          UtilsService.getMediaUrl(mediaUrl, type)

        state = StateService.getOfferStates()

        if scope.options.status?
          switch scope.options.status
            when 'active' then scope.offers = $filter('filter')(scope.offers,
              (offer) ->
                offer.status in [state.published, state.published_edited] and moment(offer.publish_to) > moment()
            )
            when 'finished' then scope.offers = $filter('filter')(scope.offers,
              (offer) ->
                offer.status in [state.published, state.published_edited] and moment(offer.publish_to) <= moment()
            )
            when 'inactive' then scope.offers = $filter('filter')(scope.offers,
              (offer) ->
                offer.status in [state.draft, state.in_review]
            )
            when 'rejected' then scope.offers = $filter('filter')(scope.offers,
              (offer) ->
                offer.status == state.rejected
            )

        if scope.options.showCharts? && scope.options.showCharts
          for offer, i in scope.offers
            if !offer.timeChartData?
              begin_date = new moment(offer.publish_from)
              end_date = new moment(offer.publish_to)
              now = new moment()

              diff_now = end_date - now
              diff_begin = end_date - begin_date

              if diff_now < 0
                diff_now = 0

              volunteers_accepted = offer.volunteers_joined_count
              volunteers_left = offer.volunteer_max_count - offer.volunteers_joined_count

              offer.timeChartData = [
                {
                  value: diff_now/diff_begin,
                  color: "#91004b"
                },
                {
                  value: 1 - (diff_now/diff_begin),
                  color: "#E2EAE9"
                }
              ]
              offer.volunteersChartData = [
                {
                  value: volunteers_accepted,
                  color: "#044c83"
                },
                {
                  value: volunteers_left,
                  color: "#E2EAE9"
                }
              ]
    )
]