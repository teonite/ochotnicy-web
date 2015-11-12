# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat").controller("AgreementTemplateEditCtrl", [
  "$scope", "$rootScope", "$state",
  "Config",
  "agreementTemplateFactory", "certificateTemplateFactory",
  "template", "offerId", "isOffer", "type", "isAdmin"
  ($scope, $rootScope, $state,
   Config,
   agreementTemplateFactory, certificateTemplateFactory,
   template, offerId, isOffer, type, isAdmin) ->
    $scope.success = false
    $scope.error = false

    if not ($rootScope.user.is_organization || $rootScope.user.is_superuser)
      $state.go("offer.list")

    $rootScope.smallBanner = true
    $rootScope.hideBanner = false
    $scope.isOffer = isOffer
    $scope.tinymceOptions = Config.tinymceOptions
    $scope.template = template

    $scope.doTheBack = ->
      window.history.back()

    switch type
      when "certificate"
        $scope.displayName = "certyfikatu"
        factory = certificateTemplateFactory
      else
        $scope.displayName = "porozumienia"
        factory = agreementTemplateFactory

    $scope.keywordSelect = 'all'
    $scope.keywords =
        #umowa
        'agreement':
           'data_rozpoczecia_umowy': 'Data rozpoczęcia umowy'
           'data_zakonczenia_umowy': 'Data zakończenia umowy'
           'zadania': 'Zadania'

        #oferta
        'offer':
          'tytul_oferty': "Tytuł oferty"
          'data_publikacji_oferty': 'Data publikacji oferty'
          'data_konca_waznosci_oferty': 'Data końca publikacji oferty'
          'maksymalna_liczba_wolontariuszy': 'Liczba wolontariuszy'
          'adres_logo_oferty': 'Logo oferty'

        #wolontariusz
        'volunteer':
          'nr_telefonu_wolontariusza': 'Numer telefonu wolontariusza'
          'wyksztalcenie_wolontariusza': 'Wykształcenie wolontariusza'
          'plec_wolontariusza': 'Płeć wolontariusza'
          'nazwa_uzytkownika_wolontariusza': 'Login wolontariusza'
          'imie_wolontariusza': 'Imię wolontariusza'
          'nazwisko_wolontariusza': 'Nazwisko wolontariusza'
          'email_wolontariusza': 'Email wolontariusza'
          'data_urodzenia_wolontariusza': 'Data urodzenia wolontariusza'
#          'pesel_wolontariusza': 'PESEL wolontariusza'
          'nr_domu_wolontariusza': 'Numer domu wolontariusza'
          'nr_mieszkania_wolontariusza': 'Numer mieszkania wolontariusza'
          'ulica_wolontariusza': 'Ulica zamieszkania wolontariusza'
          'kod_pocztowy_wolontariusza': 'Kod pocztowy wolontariusza'
          'miasto_wolontariusza': 'Miasto wolontariusza'
          'kraj_wolontariusza': 'Kraj wolontariusza'
          'nr_dowodu_wolontariusza': 'Numer dowodu wolontariusza'

        #organizacja
        'organization':
          'nazwa_organizacji': 'Nazwa organizacji'
          'typ_organizacji': 'Typ organizacji'
          'krotka_nazwa_organizacji': 'Krótka nazwa organizacji'
          'nip_organizacji': 'NIP organizacji'
          'krs_organizacji': 'KRS organizacji'
          'nr_telefonu_organizacji': 'Nr telefonu organizacji'
          'ulica_organizacji': 'Ulica organizacji'
          'nr_domu_organizacji': 'Nr domu organizacji'
          'nr_mieszkania_organizacji': 'Nr mieszkania organizacji'
          'kod_pocztowy_organizacji': 'Kod pocztowy organizacji'
          'dzielnica_organizacji': 'Dzielnica organizacji'
          'miasto_organizacji': 'Miasto organizacji'
          'wojewodztwo_organizacji': 'Województwo organizacji'
          'kraj_organizacji': 'Państwo organizacji'
          'adres_logo_organizacji': 'Logo organizacji'

    $scope.escapeKeyword = (name) ->
      "{{" + name + "}}"

    $scope.addKeyword = (tag) ->
      tinymce.activeEditor.execCommand('mceInsertContent', false, $scope.escapeKeyword(tag));
      return

    $scope.submit = ->
      console.log $scope.template
      if $scope.form.$valid
        acceptedFields = ['body', 'offer']
        if $scope.template.is_specific
          promise = factory.update({}, _.pick($scope.template, acceptedFields)).$promise
        else if isAdmin
          promise = factory.updateGlobal({}, _.pick($scope.template, acceptedFields)).$promise
        else
          $scope.template.offer = offerId
          promise = factory.save({}, _.pick($scope.template, acceptedFields)).$promise

        promise.then(
          (data) ->
            $scope.success = true
            return

          (data, status) ->
            $scope.error = true
            return
        )

        return
      else
        console.log "invalid"
        $scope.form.submitted = true
        return

    return
])
