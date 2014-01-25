/*global angular:false*/
'use strict'

const denyDefaultAction = !(event) ->
  event.preventDefault!
  event.stopPropagation!

angular.module 'angular.ujs' <[
]>
.config <[
        $provide  $injector
]> ++ !($provide, $injector) ->
  const NAME = '$getRailsCSRF'
  return if $injector.has NAME
  /*
   * Maybe provided in `ng-rails-csrf`
   */
  $provide.factory NAME, <[
         $document
  ]> ++ ($document) -> ->
    const metas       = {}
    for meta in $document.0.querySelectorAll 'meta[name^="csrf-"]'
      meta = angular.element meta
      metas[meta.attr 'name'] = meta.attr 'content'
    metas

.controller 'noopRailsConfirmCtrl' !->
  @allowAction = -> true

  @denyDefaultAction = denyDefaultAction

.controller 'RailsConfirmCtrl' <[
        $window
]> ++ !($window) ->

  @allowAction = ($attrs) ->
    const message = $attrs.confirm
    angular.isDefined message and $window.confirm message

  @denyDefaultAction = denyDefaultAction

.controller 'noopRailsRemoteFormCtrl' !->
  @submit = ($form) ->
    $form.0.submit!
    #
    then: angular.noop

.controller 'RailsRemoteFormCtrl' <[
        $scope  $parse  $http
]> ++ !($scope, $parse, $http) ->
    const successCallback = !(response) ->
      $scope.$emit 'rails:remote:success' response

    const errorCallback = !(response) ->
      $scope.$emit 'rails:remote:error' response

    @submit = ($form, modelName) ->
      const targetScope = $form.scope!
      const data = {}
      if "#modelName" isnt 'true'
        $parse modelName .assign data, targetScope.$eval(modelName)
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
      $http config .then successCallback, errorCallback

.directive 'confirm' ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const confirmCtrl = $ctrls.0
    
    const onClickHandler = !(event) ->
      confirmCtrl.denyDefaultAction event unless confirmCtrl.allowAction $attrs

    $element.on 'click' onClickHandler
    $scope.$on '$destroy' !-> $element.off 'click' onClickHandler


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

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const [
      remoteCtrl
      confirmCtrl || $controller 'noopRailsConfirmCtrl' {$scope}
    ] = $ctrls
    #
    const onSubmitHandler = !(event) ->
      confirmCtrl.denyDefaultAction event
      return unless confirmCtrl.allowAction $attrs
      #
      remoteCtrl.submit $element, $attrs.remote
    #
    # If $element.is 'a', it won't get the 'submit' event.
    # We can assume 'onSubmitHandler' will be triggered on 'form' $element.
    #  
    $element.on 'submit' onSubmitHandler
    $scope.$on '$destroy' !-> $element.off 'submit' onSubmitHandler

  require: <[ remote ?confirm ]>
  restrict: 'A'
  controller: 'RailsRemoteFormCtrl'
  compile: (tElement, tAttrs) ->
    return if tAttrs.$attr.remote isnt 'data-remote'
    postLinkFn

.directive 'method' <[
       $controller  $compile  $document  $getRailsCSRF
]> ++ ($controller, $compile, $document, $getRailsCSRF) ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const [
      confirmCtrl || $controller 'noopRailsConfirmCtrl' {$scope}
      remoteCtrl  || $controller 'noopRailsRemoteFormCtrl' {$scope}
    ] = $ctrls

    const onClickHandler = !(event) ->
      confirmCtrl.denyDefaultAction event if confirmCtrl.allowAction $attrs

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

      <-! remoteCtrl.submit $form, true .then
      childScope.$destroy!
      $form.remove!

    $element.on 'click' onClickHandler
    $scope.$on '$destroy' !-> $element.off 'click' onClickHandler


  require: <[ ?confirm ?remote ]>
  restrict: 'A'
  compile: (tElement, tAttrs) ->
    return if tAttrs.$attr.method isnt 'data-method'
    postLinkFn
