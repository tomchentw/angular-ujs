/*global angular:false*/
let angular = angular, bind = angular.bind
  'use strict'

  !function denyDefaultAction (event)
    event.preventDefault!
    event.stopPropagation!

  angular.module 'angular.ujs' <[
  ]>
  .factory '$getRailsCSRF' <[
         $document
  ]> ++ ($document) ->
    ->
      const metas       = {}
      for meta in $document.0.querySelectorAll 'meta[name^="csrf-"]'
        meta = angular.element meta
        metas[meta.attr 'name'] = meta.attr 'content'
      metas

  .controller 'noopRailsConfirmCtrl' class

    allowAction: -> true

    denyDefaultAction: denyDefaultAction

  .controller 'RailsConfirmCtrl' class

    allowAction: ->
      const message = @$attrs.confirm
      angular.isDefined message and @$window.confirm message

    denyDefaultAction: denyDefaultAction

    @$inject = <[
       $window   $attrs ]>
    !(@$window, @$attrs) ->

  .controller 'noopRailsRemoteFormCtrl' class

    submit: ($form) ->
      $form.0.submit!
      #
      then: angular.noop

  .controller 'RailsRemoteFormCtrl' class

    submit: ($form) ->
      const targetScope = $form.scope!
      const modelName = @$attrs.remote
      const data = {}

      if "#modelName" isnt 'true'
        @$parse modelName .assign data, targetScope.$eval(modelName)
      else
        for own key, value of targetScope
          continue if key is 'this' || key.0 is '$'
          data[key] = value
      #
      const config = do
        url: $form.attr 'action'
        method: $form.attr 'method'
        data: data
      #
      # Rails 4 bug here:
      #   http://stackoverflow.com/a/1935237/1458162
      #
      const METHOD = data._method
      if METHOD isnt 'GET' and METHOD isnt 'POST'
        config.headers = 'X-Http-Method-Override': METHOD
      #
      @$http config .then @successCallback, @errorCallback

    successCallback: !(response) ->
      @$scope.$emit 'rails:remote:success' response

    errorCallback: !(response) ->
      @$scope.$emit 'rails:remote:error' response

    @$inject = <[
       $scope   $attrs   $parse   $http ]>
    !(@$scope, @$attrs, @$parse, @$http) ->
      @successCallback = bind @, @successCallback
      @errorCallback = bind @, @errorCallback

  .directive 'confirm' ->

    !function onClickHandler (confirmCtrl, event)
      confirmCtrl.denyDefaultAction event unless confirmCtrl.allowAction!

    !function postLinkFn ($scope, $element, $attrs, $ctrls)
      const callback = bind void, onClickHandler, $ctrls.0

      $element.on 'click' callback
      $scope.$on '$destroy' !-> $element.off 'click' callback


    restrict: 'A'
    require: <[ confirm ]>
    controller: 'RailsConfirmCtrl'
    compile: (tElement, tAttrs) ->
      const {$attr} = tAttrs
      #
      # Do nothing here, just inject RailsConfirmCtrl
      #
      return if $attr.confirm isnt 'data-confirm' or $attr.remote is 'data-remote' or $attr.method is 'data-method'
      postLinkFn

  .directive 'remote' <[
         $controller
  ]> ++ ($controller) ->

    !function onSubmitHandler ($element, $ctrls, event)
      $ctrls.1.denyDefaultAction event

      if $ctrls.1.allowAction!
        $ctrls.0.submit $element

    !function postLinkFn ($scope, $element, $attrs, $ctrls)
      $ctrls.1 = $controller 'noopRailsConfirmCtrl' {$scope} unless $ctrls.1

      const callback = bind void, onSubmitHandler, $element, $ctrls
      #
      # If $element.is 'a', it won't get the 'submit' event.
      # We can assume 'onSubmitHandler' will be triggered on 'form' $element.
      #
      $element.on 'submit' callback
      $scope.$on '$destroy' !-> $element.off 'submit' callback


    require: <[ remote ?confirm ]>
    restrict: 'A'
    controller: 'RailsRemoteFormCtrl'
    compile: (tElement, tAttrs) ->
      return if tAttrs.$attr.remote isnt 'data-remote'
      postLinkFn

  .directive 'method' <[
         $controller  $compile  $document  $getRailsCSRF
  ]> ++ ($controller, $compile, $document, $getRailsCSRF) ->

    !function onClickHandler ($scope, $attrs, $ctrls, event)
      $ctrls.0.denyDefaultAction event if $ctrls.0.allowAction!

      const metaTags    = $getRailsCSRF!
      const childScope  = $scope.$new!
      const $form       = $compile("""
        <form class="ng-hide" method="POST" action="#{ $attrs.href }">
          <input type="text" name="_method" ng-model="_method">
          <input type="text" name="#{ metaTags['csrf-param'] }" value="#{ metaTags['csrf-token'] }">
        </form>
      """)(childScope)
      $document.find 'body' .append $form

      childScope.$apply !-> childScope._method = $attrs.method

      <-! $ctrls.1.submit $form .then
      childScope.$destroy!
      $form.remove!

    !function postLinkFn ($scope, $element, $attrs, $ctrls)
      const controllerArgs = {$scope, $attrs}
      $ctrls.0 = $controller 'noopRailsConfirmCtrl' controllerArgs unless $ctrls.0
      $ctrls.1 = $controller 'noopRailsRemoteFormCtrl' controllerArgs unless $ctrls.1

      const callback = bind $ctrls, onClickHandler, $scope, $attrs, $ctrls

      $element.on 'click' callback
      $scope.$on '$destroy' !-> $element.off 'click' callback


    require: <[ ?confirm ?remote ]>
    restrict: 'A'
    compile: (tElement, tAttrs) ->
      return if tAttrs.$attr.method isnt 'data-method'
      postLinkFn
