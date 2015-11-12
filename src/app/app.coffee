# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat", [
  "ui.router"
  "ngCookies"
  "ngResource"
  "ngAria"
  "ngSanitize"
  "ngMessages"
  "localytics.directives"
  "ui.bootstrap"
  "ui.tinymce"
  "ui.utils"
  "wolontariat.services"
  "wolontariat.directives"
  "wolontariat.templates"
  "wolontariat.templates.directives"
  "wolontariat.filters"
  "angularAuth"
  "angularMoment"
  "angles"
  "uiGmapgoogle-maps"
  "angularFileUpload"
  "angularUtils.directives.dirPagination"
  "ngStorage"
  "cgNotify"
  "ipCookie"
]).factory("httpInterceptor", ($q, $injector, $rootScope) ->
  $rootScope.showLoader = false
  $rootScope.http = null
  $rootScope.errorModal = false
  return {
    'request': (config) ->
      $rootScope.showLoader = true
      return config || $q.when(config)
    'requestError': (rejection) ->
      $rootScope.http = $rootScope.http || $injector.get('$http')
      if ($rootScope.http.pendingRequests.length < 1)
        $rootScope.showLoader = false
      return $q.reject(rejection)
    'response': (response) ->
      $rootScope.http = $rootScope.http || $injector.get('$http')
      $injector.get('$rootScope')['backendVersion'] = response.headers('X-Backend-Version')
      if ($rootScope.http.pendingRequests.length < 1)
        $rootScope.showLoader = false
      return response || $q.when(response)
    'responseError': (rejection) ->
      $rootScope.http = $rootScope.http || $injector.get('$http')
      if ($rootScope.http.pendingRequests.length < 1)
        $rootScope.showLoader = false

      currentState = $injector.get('$state').current

      if(currentState.hasOwnProperty('data') and
      currentState.data.hasOwnProperty('ignoreStatuses') and
      rejection.status in currentState.data.ignoreStatuses)
        return $q.reject(rejection)

      switch rejection.status
        when 310
          if $rootScope.user.is_superuser
            $injector.get('$state').go('admin.offers')
          else
            $injector.get('$state').go('profileRegister')
        when 400 then break
        when 403
          $injector.get('$state').go('offer.list')
          $rootScope.errorModal = true
          $rootScope.error =
            'status': rejection.status
            'msg': "Brak uprawnień do danego zasobu"
            'type': "application/json"
        when 404
          $injector.get('$state').go('offer.list')
          $rootScope.errorModal = true
          $rootScope.error =
            'status': rejection.status
            'msg': "Nie znaleziono danego zasobu"
            'type': "application/json"
        when 409 then break
        when 440 then break
        else
          $rootScope.errorModal = true
          $rootScope.error =
            'status': rejection.status
            'msg': rejection.data
            'type': rejection.headers('content-type')
      $q.reject(rejection)
  }
).config([
    '$urlMatcherFactoryProvider',
    ($urlMatcherFactoryProvider) ->
      $urlMatcherFactoryProvider.caseInsensitive(true)
      $urlMatcherFactoryProvider.strictMode(false)
      return
]).config([
  "$stateProvider", "$urlRouterProvider", "$locationProvider"
  ($stateProvider, $urlRouterProvider, $locationProvider) ->
    $locationProvider.html5Mode(true).hashPrefix('!');
#    $urlRouterProvider.rule ($injector, $location) ->
#      path = $location.url()
#
#      # check to see if the path already has a slash where it should be
#      return if path.indexOf('#') != -1 && path.indexOf('#!') == -1
#      return if path[path.length - 1] is "/" or path.indexOf("/?") > -1
#      return path.replace("?", "/?") if path.indexOf("?") > -1
#      path + "/"

    $stateProvider.state("logout"
      url: "/logout"
      controller: "LogoutCtrl"
    ).state("login"
      url: "/login"
      controller: "LoginCtrl"
      data:
        unrestricted: true
        ignoreStatuses: [405, ]
    ).state("activation"
      url: "/activation/{hash:[0-9a-fA-F]{40}}"
      controller: "ActivationCtrl"
      template: '<ui-view/>'
      resolve:
        instanceName: (settingsFactory) ->
          settingsFactory.get({'id': 'instance_name'}).$promise
      data:
        unrestricted: true
    ).state('profileRegister'
      url: "/profile/register"
      templateUrl: "profileRegistration.html"
      controller: "ProfileRegistrationCtrl"
      resolve:
        countries: (countryFactory) ->
          countryFactory.query().$promise
        education: (educationFactory) ->
          educationFactory.query().$promise
        abilities: (abilityFactory) ->
          abilityFactory.query().$promise
        organizationTypes: (organizationTypeFactory) ->
          organizationTypeFactory.query().$promise
    ).state('profileRegisterPhoto'
      url: "/profile/register/photo"
      templateUrl: "profileRegistrationPhoto.html"
      controller: "ProfileRegistrationPhotoCtrl"
      data:
        ignoreStatuses: [413, ]
      resolve:
        profile: (organizationFactory, volunteerFactory, $rootScope) ->
          if $rootScope.user.is_volunteer
            volunteerFactory.get({id: 'my'}).$promise
          else
            organizationFactory.get({organizationId: 'my'}).$promise

    ).state('offer'
      abstract: true
      template: '<ui-view/>'
      resolve:
        promotedOffers: (offerFactory) ->
          console.log 'In offer abstract state resolve'
          prom = offerFactory.getPromotedOffers().$promise
          return prom
    ).state("offer.list"
      url: "/"
      controller: "OfferListCtrl"
      templateUrl: "offerList.html"
      data:
        unrestricted: true
      resolve:
        offerList: (offerFactory) ->
          console.log 'In offer.list state resolve'
          prom = offerFactory.getOffersWithCategories().$promise
          console.log prom
          return prom
        fbAppId: (settingsFactory) ->
          settingsFactory.get({'id': 'facebook_appid'}).$promise
        projectsLimit: (settingsFactory) ->
          settingsFactory.get({'id': 'main_page_projects'}).$promise
        id: ->
          null
    ).state("offer.tags"
      url: "/tag/:id"
      controller: "OfferListCtrl"
      templateUrl: "offerList.html"
      data:
        unrestricted: true
      resolve:
        offerList: (offerFactory, $stateParams) ->
          offerFactory.getOffersWithCategories().$promise
        id: ($stateParams) ->
          parseInt($stateParams.id)
    ).state("offer.edit"
      url: "/offer/edit/:step/:id"
      controller: "OfferEditCtrl"
      templateUrl: ($stateParams) ->
        $stateParams.step = parseInt(
          (if $stateParams.step then $stateParams.step else 1)
        )
        if $stateParams.step > 5
          $stateParams.step = 5
        if $stateParams.step is 5
          return "offerDetails.html"
        return "offerEdit" + $stateParams.step + ".html"
      data:
        ignoreStatuses: [404, 413, ]
      resolve:
        categories: (categoryFactory) ->
          categoryFactory.query().$promise
        offer: (offerFactory, $stateParams) ->
          offerFactory.get({offerId: $stateParams.id}).$promise
        step: ($stateParams) ->
          $stateParams.step = if $stateParams.step then $stateParams.step else 1
          step = parseInt($stateParams.step)
          if step > 5
            step = 5
          return step
        isNew: ->
          false
        organization: (organizationFactory, $stateParams) ->
          organizationFactory.get({organizationId: 'my'}).$promise
    ).state("offer.new"
      url: "/offer/new"
      controller: "OfferEditCtrl"
      templateUrl: "offerEdit1.html"
      resolve:
        categories: (categoryFactory) ->
          categoryFactory.query().$promise
        offer: ->
          {
            publish_from: moment().format(),
            volunteer_max_count: 1
          }
        step: ->
          1
        isNew: ->
          true
        organization: (organizationFactory, $stateParams) ->
          organizationFactory.get({organizationId: 'my'}).$promise
    ).state('offer.certificate'
      abstract: true
      template: '<ui-view/>'
    ).state("offer.certificate.template"
      url: "/offer/:id/certificate/template"
      controller: "AgreementTemplateEditCtrl"
      templateUrl: "agreementTemplateEdit.html"
      resolve:
        offerId: ($stateParams) ->
          $stateParams.id
        template: (offerFactory, $stateParams) ->
          offerFactory.getCertificateTemplate({offerId: $stateParams.id}).$promise
        isOffer: ->
          true
        type: ->
          'certificate'
        isAdmin: ->
          false
    ).state('offer.agreement'
      abstract: true
      template: '<ui-view/>'
    ).state("offer.agreement.template"
      url: "/offer/:id/agreement/template"
      controller: "AgreementTemplateEditCtrl"
      templateUrl: "agreementTemplateEdit.html"
      resolve:
        offerId: ($stateParams) ->
          $stateParams.id
        template: (offerFactory, $stateParams) ->
          offerFactory.getAgreementTemplate({offerId: $stateParams.id}).$promise
        isOffer: ->
          true
        type: ->
          'agreement'
        isAdmin: ->
          false
    ).state("offer.agreement.details"
      url: "/offer/:id/agreement/details"
      controller: "OfferAgreementDetailCtrl"
      templateUrl: "offerAgreementDetail.html"
      data:
        ignoreStatuses: [404, ]
      resolve:
        offer: ($stateParams, offerFactory) ->
          offerFactory.get({offerId: $stateParams.id}).$promise
        signatories: (organizationFactory, $rootScope) ->
          organizationFactory.getSignatories({
            organizationId: $rootScope.user.organization_id
          }).$promise
    ).state("offer.details"
      url: "/offer/:id"
      controller: "OfferDetailsCtrl"
      templateUrl: "offerDetails.html"
      data:
        unrestricted: true
        ignoreStatuses: [403, 404]
      resolve:
        offer: (offerFactory, $stateParams) ->
          offerFactory.get({offerId: $stateParams.id}).$promise
        userApplication: (offerFactory, $rootScope, $stateParams) ->
          if $rootScope.user? && $rootScope.user.is_volunteer
            return offerFactory.checkApplication({
              offerId: $stateParams.id
            }).$promise
          return {'application': null}
        fbAppId: (settingsFactory) ->
          settingsFactory.get({'id': 'facebook_appid'}).$promise
    ).state('organization'
      abstract: true
      template: '<ui-view/>'
      resolve:
        promotedOffers: (offerFactory) ->
          offerFactory.getPromotedOffers().$promise
    ).state('organization.agreement'
      abstract: true
      template: '<ui-view/>'
    ).state("organization.agreement.template"
      url: "/organization/agreement/template"
      controller: "AgreementTemplateEditCtrl"
      templateUrl: "agreementTemplateEdit.html"
      resolve:
        offerId: () ->
          undefined
        template: (organizationFactory) ->
          organizationFactory.getAgreementTemplate({
            organizationId: 'my'
          }).$promise
        isOffer: ->
          false
        type: ->
          'agreement'
        isAdmin: ->
          false
    ).state('organization.certificate'
      abstract: true
      template: '<ui-view/>'
    ).state("organization.certificate.template"
      url: "/organization/certificate/template"
      controller: "AgreementTemplateEditCtrl"
      templateUrl: "agreementTemplateEdit.html"
      resolve:
        offerId: () ->
          undefined
        template: (organizationFactory) ->
          organizationFactory.getCertificateTemplate({
            organizationId: 'my'
          }).$promise
        isOffer: ->
          false
        type: ->
          'certificate'
        isAdmin: ->
          false
    ).state("organization.edit"
      url: "/organization/edit"
      controller: "OrganizationEditCtrl"
      templateUrl: "organizationEdit.html"
      data:
        ignoreStatuses: [413, ]
      resolve:
        organization: (organizationFactory, $stateParams) ->
          organizationFactory.get({organizationId: 'my'}).$promise
        countries: (countryFactory) ->
          countryFactory.query().$promise
        organizationTypes: (organizationTypeFactory) ->
          organizationTypeFactory.query().$promise
    ).state("organization.help"
      url: "/organization/help"
      controller: "PlainHtmlCtrl"
      templateUrl: "organizationHelp.html"
      resolve:
        banner: ->
          return {
            small: false
            class: 'dla-organizacji'
            title: 'Dla Organizacji'
            description: 'Dodawaj oferty i angażuj ochotników do swoich działań.'
            hideHowLink: true
            hideFB: true
            hideMain: true
          }
        scrollTo: ->
          ""
        promotedOffers: (offerFactory) ->
          offerFactory.getPromotedOffers().$promise
      onExit: ($rootScope) ->
        $rootScope.banner = {}
        return
      data:
        unrestricted: true
    ).state('organization.offers',
      url: "/organization/:id/list"
      controller: "OrganizationProfileCtrl"
      templateUrl: "organizationProfile.html"
      resolve:
        isList: ->
          true
        organization: (organizationFactory, $stateParams) ->
          organizationFactory.get({organizationId: $stateParams.id}).$promise
        offers: (organizationFactory, $stateParams, $rootScope, StateService) ->
          statuses = StateService.getOfferStates()
          statusList = [statuses.published, statuses.published_edited]

          isSelfProfile = $rootScope.user? and $rootScope.user.organization_id == parseInt($stateParams.id)
          if $stateParams.id == "my" or isSelfProfile
            statusList = []

          organizationFactory.getOffers({
            organizationId: $stateParams.id
          }, status: statusList).$promise
        evaluations: ->
          []
      data:
        unrestricted: true
    ).state('organization.ratings',
      url: "/organization/:id/ratings"
      controller: "OrganizationRatingListCtrl"
      templateUrl: "organizationRatingList.html"
      resolve:
        organization: (organizationFactory, $stateParams) ->
          organizationFactory.get({organizationId: $stateParams.id}).$promise
        ratings: (organizationFactory, $stateParams) ->
          organizationFactory.getRatings({organizationId: $stateParams.id}).$promise
    ).state('organization.profile',
      url: "/organization/:id"
      controller: "OrganizationProfileCtrl"
      templateUrl: "organizationProfile.html"
      resolve:
        isList: ->
          false
        organization: (organizationFactory, $stateParams) ->
          organizationFactory.get({organizationId: $stateParams.id}).$promise
        offers: (organizationFactory, $stateParams, $rootScope, StateService) ->
          statuses = StateService.getOfferStates()
          statusList = [statuses.published, statuses.published_edited]

          if $stateParams.id == "my" or ($rootScope.user? and
          $rootScope.user.organization_id == parseInt($stateParams.id))
            statusList = []
          organizationFactory.getOffers({
            organizationId: $stateParams.id
          }, status: statusList).$promise
        evaluations: (organizationFactory, $stateParams) ->
          organizationFactory.getRatings({organizationId: $stateParams.id}).$promise
      data:
        unrestricted: true
    ).state('volunteer'
      abstract: true
      template: '<ui-view/>'
      resolve:
        promotedOffers: (offerFactory) ->
          offerFactory.getPromotedOffers().$promise
    ).state("volunteer.applications"
      url: "/volunteer/applications"
      controller: "VolunteerApplicationsCtrl"
      templateUrl: "volunteerApplications.html"
      resolve:
        profile: (volunteerFactory) ->
          volunteerFactory.get({id: "my"}).$promise
        applications: (volunteerFactory) ->
          volunteerFactory.getApplications({id: "my"}).$promise
        agreements: (volunteerFactory) ->
          volunteerFactory.getAgreements({id: 'my'}).$promise
        certificates: (volunteerFactory) ->
          volunteerFactory.getCertificates({id: 'my'}).$promise
    ).state("volunteer.edit"
      url: "/volunteer/edit"
      controller: "VolunteerEditCtrl"
      templateUrl: "volunteerEdit.html"
      data:
        ignoreStatuses: [413, ]
      resolve:
        profile: (volunteerFactory, $stateParams) ->
          volunteerFactory.get({id: 'my'}).$promise
        education: (educationFactory) ->
          educationFactory.query().$promise
        abilities: (abilityFactory) ->
          abilityFactory.query().$promise
        countries: (countryFactory) ->
          countryFactory.query().$promise
    ).state("volunteer.help"
      url: "/volunteer/help"
      controller: "PlainHtmlCtrl"
      templateUrl: "volunteerHelp.html"
      data:
        unrestricted: true
      resolve:
        banner: ->
          return {
            small: false
            class: 'dla-ochotnika'
            title: 'Dla Ochotnika'
            description: '<p>Znajdź inicjatywę, która Cię interesuje i dołącz do naszej społeczności!</p>'
            hideHowLink: true
            hideFB: true
            hideMain: true
          }
        scrollTo: ->
          ""
        promotedOffers: (offerFactory) ->
          offerFactory.getPromotedOffers().$promise
      onExit: ($rootScope) ->
        $rootScope.banner = {}
        return
    ).state("volunteer.ratings"
      url: "/volunteer/:id/ratings"
      controller: "VolunteerRatingListCtrl"
      templateUrl: "volunteerRatingList.html"
      resolve:
        profile: (volunteerFactory, $stateParams) ->
          volunteerFactory.get({id: $stateParams.id}).$promise
        ratings: (volunteerFactory, $stateParams) ->
          volunteerFactory.getRatings({id: $stateParams.id}).$promise
    ).state("volunteer.profile"
      url: "/volunteer/:id"
      controller: "VolunteerProfileCtrl"
      templateUrl: "volunteerProfile.html"
      resolve:
        profile: (volunteerFactory, $stateParams) ->
          volunteerFactory.get({id: $stateParams.id}).$promise
        applications: (volunteerFactory, $stateParams) ->
          volunteerFactory.getApplications({id: $stateParams.id}).$promise
        agreements: (volunteerFactory, $stateParams, $rootScope) ->
          if !($stateParams.id is 'my' or $stateParams.id is $rootScope.volunteer_id)
            return []
          return volunteerFactory.getAgreements({id: 'my'}).$promise
        certificates: (volunteerFactory, $stateParams, $rootScope) ->
          if !($stateParams.id is 'my' or $stateParams.id is $rootScope.volunteer_id)
            return []
          return volunteerFactory.getCertificates({id: 'my'}).$promise
        evaluations: (volunteerFactory, $stateParams) ->
          volunteerFactory.getRatings({id: $stateParams.id}).$promise
    ).state('news'
      abstract: true
      template: '<ui-view/>'
      resolve:
        promotedOffers: (offerFactory) ->
          prom = offerFactory.getPromotedOffers().$promise
          return prom
    ).state("news.list"
      url: "/news"
      controller: "NewsListCtrl"
      templateUrl: "newsList.html"
      data:
        unrestricted: true
      resolve:
        newsList: (newsFactory) ->
          newsFactory.query().$promise
    ).state("news.details"
      url: "/news/:id"
      controller: "NewsDetailsCtrl"
      templateUrl: "newsDetails.html"
      data:
        unrestricted: true
      resolve:
        news: (newsFactory, $stateParams) ->
          newsFactory.get({id: $stateParams.id}).$promise
    ).state('admin'
      abstract: true
      template: '<ui-view/>'
      data:
        ignoreStatuses: [310]
      resolve:
        is_superuser: ($rootScope, $q, $state) ->
          deferred = $q.defer()
          if $rootScope.user? && $rootScope.user.is_superuser
            deferred.resolve()
          else
            $state.go('offer.list')
            $rootScope.errorModal = true
            $rootScope.error =
              'status': 403
              'msg': "Brak uprawnień do danego zasobu"

            deferred.reject()
          deferred.promise
    ).state("admin.agreement_template"
      url: "/panel/agreement"
      controller: "AgreementTemplateEditCtrl"
      templateUrl: "agreementTemplateEdit.html"
      resolve:
        offerId: ->
          null
        template: (agreementTemplateFactory) ->
          agreementTemplateFactory.getGlobal().$promise
        isOffer: ->
          false
        type: ->
          'agreement'
        isAdmin: ->
          true
    ).state("admin.certificate_template"
      url: "/panel/certificate"
      controller: "AgreementTemplateEditCtrl"
      templateUrl: "agreementTemplateEdit.html"
      resolve:
        offerId: ->
          null
        template: (certificateTemplateFactory) ->
          certificateTemplateFactory.getGlobal().$promise
        isOffer: ->
          false
        type: ->
          'certificate'
        isAdmin: ->
          true
    ).state("admin.offers"
      url: "/panel/offers"
      controller: "AdminOfferListCtrl"
      templateUrl: "adminOfferList.html"
      resolve:
        offerList: (offerFactory) ->
          prom = offerFactory.getAdminList().$promise
          return prom
    ).state('admin.news'
      abstract: true
      template: '<ui-view/>'
      data:
        ignoreStatuses: [413]
    ).state("admin.news.add"
      url: "/panel/news"
      controller: "AdminNewsAddCtrl"
      templateUrl: "adminNewsAdd.html"
      resolve:
        news: ->
          {}
    ).state("admin.news.edit"
      url: "/panel/news/:id"
      controller: "AdminNewsAddCtrl"
      templateUrl: "adminNewsAdd.html"
      resolve:
        news: (newsFactory, $stateParams) ->
          newsFactory.get({id: $stateParams.id}).$promise
    ).state("admin.metrics"
      url: "/panel/metrics"
      controller: "AdminMetricsCtrl"
      templateUrl: "adminMetrics.html"
      resolve:
        metrics: (metricsFactory) ->
          metricsFactory.query().$promise
    ).state("admin.organizations"
      url: "/panel/organizations"
      controller: "AdminOrganizationsCtrl"
      templateUrl: "adminOrganizations.html"
      resolve:
        organizations: (organizationFactory) ->
          organizationFactory.query().$promise
    ).state("admin.volunteers"
      url: "/panel/volunteers"
      controller: "AdminVolunteersCtrl"
      templateUrl: "adminVolunteers.html"
      resolve:
        volunteers: (volunteerFactory) ->
          volunteerFactory.query().$promise
    ).state("howItWorks"
      url: "/howItWorks"
      controller: "PlainHtmlCtrl"
      templateUrl: "howItWorks.html"
      data:
        unrestricted: true
      resolve:
        banner: ->
          return {
            small: false
            class: 'jak-to-dziala'
            title: 'Jak to działa?'
            description: '<p>Łączymy chęci i umiejętności ochotników z najlepszymi inicjatywami w mieście.</p>'
            hideHowLink: true
            hideFB: true
            hideMain: true
          }
        scrollTo: ->
          ""
        promotedOffers: (offerFactory) ->
          offerFactory.getPromotedOffers().$promise
      onExit: ($rootScope) ->
        $rootScope.banner = {}
        return
    ).state("contact"
      url: "/contact"
      controller: "PlainHtmlCtrl"
      templateUrl: "contact.html"
      data:
        unrestricted: true
      resolve:
        banner: ->
          {}
        scrollTo: ->
          ""
        promotedOffers: (offerFactory) ->
          offerFactory.getPromotedOffers().$promise
    ).state("about"
      url: "/about"
      controller: "PlainHtmlCtrl"
      templateUrl: "aboutUs.html"
      data:
        unrestricted: true
      resolve:
        banner: ->
          {}
        scrollTo: ($stateParams) ->
          ""
        promotedOffers: (offerFactory) ->
          offerFactory.getPromotedOffers().$promise
    ).state("about.scroll"
      url: "#:scrollTo"
      resolve:
        scrollTo: ($stateParams) ->
          $stateParams.scrollTo
    ).state("terms"
      url: "/terms"
      controller: "PlainHtmlCtrl"
      templateUrl: "terms.html"
      data:
        unrestricted: true
      resolve:
        banner: ->
          {}
        promotedOffers: ->
          []
        scrollTo: ->
          ""
    ).state("privacy"
      url: "/privacy"
      controller: "PlainHtmlCtrl"
      templateUrl: "privacy.html"
      data:
        unrestricted: true
      resolve:
        banner: ->
          {}
        promotedOffers: ->
          []
        scrollTo: ->
          ""
    )

    $urlRouterProvider.otherwise ($injector) ->
      $state = $injector.get('$state')
      $location = $injector.get('$location')
      Config = $injector.get('Config')

      url = $location.url()
      url = url.split('/')

      if url[1] in ['static', 'media']
        window.location = Config.staticRoot + $location.url()
      else
        $state.go 'offer.list'
      return

    return
]).run(["amMoment", '$rootScope', '$cookies', '$http', 'AuthService', (amMoment, $rootScope, $cookies, $http, AuthService) ->
  amMoment.changeLocale "pl"

  if $cookies.token
    $http.defaults.headers.common["Authorization"] = "Token " + $cookies.token
    AuthService.checkAuth().then(
      (result) ->
        $rootScope.user = result
        $rootScope.session = AuthService.createSessionFor(result)
        return
      (errors) ->
        if (!errors || (errors["detail"] == "Invalid token" || errors["detail"] == "Authentication credentials were not provided."))
          delete $cookies['token']
          delete $http.defaults.headers.common["Authorization"]
        return
    )
  return
]).config(['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push "httpInterceptor"
  return
]).config(['paginationTemplateProvider', (paginationTemplateProvider) ->
  paginationTemplateProvider.setPath "pagination.html"
  return
]).config(['uiGmapGoogleMapApiProvider', (uiGmapGoogleMapApiProvider) ->
    uiGmapGoogleMapApiProvider.configure({
      #key: 'your api key',
      v: '3.17'
      libraries: ''
      language: 'pl'
    })
    return
])

angular.module("wolontariat").factory "Config", ['$location',
  ($location) ->
    removeLastSlash = (str) ->
      if str[str.length - 1] == "/"
        str.slice(0, str.length - 1)
      else str;

    currentBase = $location.protocol() + "://" + $location.host() + if $location.port() != 80 then ":"+$location.port() else ''

    backendRoots = backendRoot or removeLastSlash(currentBase)
    staticRoots = staticRoot or removeLastSlash(currentBase)
    apiRoots = apiRoot or removeLastSlash(backendRoots + "/v1/api/")

    ret =
      apiRoot: apiRoots
      backendRoot: backendRoots
      staticRoot: staticRoots
      pageSize: 10
      tinymceOptions : tinyMce
      version: webappVersion

    return ret
]

# COMMON MODULES
angular.module "wolontariat.services", []
angular.module "wolontariat.directives", []
angular.module "wolontariat.filters", []
angular.module "wolontariat.templates", []
angular.module "wolontariat.templates.directives", []