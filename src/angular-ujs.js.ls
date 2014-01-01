const denyDefaultAction = !(event) ->
  event.preventDefault!
  event.stopPropagation!

angular.module 'angular.ujs' <[]>
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

.controller 'noopRailsRemoteFormCtrl' !->
  @submit = ($form) ->
    $form.0.submit!
    #
    then: angular.noop

.factory 'rails' <[
       $window  $document  $compile
]> ++ ($window, $document, $compile) ->

  const getMetaTags = ->
    const metas       = {}
    const metasArray  = $document.find 'meta'
    for i from 0 til metasArray.length
      const meta = metasArray.eq i
      metas[meta.attr 'name'] = meta.attr 'content'
    metas
 
  getMetaTags: getMetaTags

  createMethodFormElement: ($attrs, $scope) ->
    const metaTags = getMetaTags!
    const childScope = $scope.$new!

    const $form = $compile("""
      <form class="ng-hide" method="POST" action="#{ $attrs.href }">
        <input type="text" name="_method" ng-model="_method">
        <input type="text" name="#{ metaTags['csrf-param'] }" value="#{ metaTags['csrf-token'] }">
      </form>
    """)(childScope)
    $document.find 'body' .append $form
    
    childScope.$apply !-> childScope._method = $attrs.method
    $form

  noopConfirmCtrl: !->
    @allowAction = -> true

    @denyDefaultAction = !(event) ->
      event.preventDefault!
      event.stopPropagation!

  noopRemoteFormCtrl: !->
    @submit = ($form) ->
      $form.0.submit!
      #
      then: angular.noop

.controller 'RailsConfirmCtrl' <[
        $window  rails
]> ++ !($window, rails) ->

  @allowAction = ($attrs) ->
    const message = $attrs.confirm
    angular.isDefined message and $window.confirm message

  @denyDefaultAction = denyDefaultAction

.directive 'confirm' ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const confirmCtrl = $ctrls.0
    
    const onClickHandler = !(event) ->
      confirmCtrl.denyDefaultAction event unless confirmCtrl.allowAction $attrs

    $element.on 'click' onClickHandler
    $scope.$on '$destroy' !-> $element.off 'click' onClickHandler


  restrict: 'A'
  require: <[confirm]>
  compile: (tElement, tAttrs) ->
    const {$attr} = tAttrs
    return if $attr.confirm isnt 'data-confirm' or $attr.remote is 'data-remote' or $attr.method is 'data-method'
    
    postLinkFn

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
        console.log 'parsing modelName' modelName
        $parse modelName .assign data, targetScope.$eval(modelName)
      else
        for own key, value of targetScope
          continue if key is 'this' || key.0 is '$'
          data[key] = value
      console.log data, modelName, modelName is true
      $http do
        method: $form.attr 'method'
        url: $form.attr 'action'
        data: data
      .then successCallback, errorCallback

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
      confirmCtrl.denyDefaultAction event if confirmCtrl.allowAction $attrs
      #
      remoteCtrl.submit $element, $attrs.remote
    #
    # If $element.is 'a', it won't get the 'submit' event.
    # We can assume 'onSubmitHandler' will be triggered on 'form' $element.
    #  
    $element.on 'submit' onSubmitHandler
    $scope.$on '$destroy' !-> $element.off 'submit' onSubmitHandler

  require: <[remote ?confirm]>
  restrict: 'A'
  controller: 'RailsRemoteFormCtrl'
  compile: (tElement, tAttrs) ->
    return if tAttrs.$attr.remote isnt 'data-remote'
    postLinkFn

.directive 'method' <[
       $controller  rails
]> ++ ($controller, rails) ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const [
      confirmCtrl || $controller 'noopRailsConfirmCtrl' {$scope}
      remoteCtrl  || $controller 'noopRailsRemoteFormCtrl' {$scope}
    ] = $ctrls
    console.log remoteCtrl

    const onClickHandler = !(event) ->
      console.log 'onClickHandler'
      confirmCtrl.denyDefaultAction event if confirmCtrl.allowAction $attrs
      
      const $form = rails.createMethodFormElement $attrs, $scope

      console.log 'before remoteCtrl.submit'
      <-! remoteCtrl.submit $form, true .then
      $form.scope!$destroy!
      $form.remove!

    console.log 'setup onClickHandler'
    $element.on 'click' onClickHandler
    $scope.$on '$destroy' !-> $element.off 'click' onClickHandler


  require: <[?confirm ?remote]>
  restrict: 'A'
  compile: (tElement, tAttrs) ->
    return if tAttrs.$attr.method isnt 'data-method'
    postLinkFn

