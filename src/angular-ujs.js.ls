angular.module 'angular.ujs' <[]>
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

  confirmAction: (message, $event) ->
    const answer = angular.isDefined message and $window.confirm message
    unless answer
      $event.preventDefault!
      $event.stopPropagation!
    answer
 
  getMetaTags: getMetaTags

  createMethodFormElement: ($attrs, $scope) ->
    const metaTags = getMetaTags!
    const $form = $compile("""
      <form class="ng-hide" method="POST" action="#{ $attrs.href }">
        <input type="text" name="_method" ng-model="link._method">
        <input type="text" name="#{ metaTags['csrf-param'] }" value="#{ metaTags['csrf-param'] }">
      </form>
    """)($scope.$new!)
    $document.find 'body' .append $form

    $form.find 'input' .eq 0 .val $attrs.method .change!
    $form

  noopRemoteFormCtrl: !->
    @submit = ->
      then: angular.noop

.controller 'RailsRemoteFormCtrl' <[
        $scope  $http
]> ++ !($scope, $http) ->
    const successCallback = !(response) ->
      $scope.$emit 'rails:remote:success' response

    const errorCallback = !(response) ->
      $scope.$emit 'rails:remote:error' response

    @submit = ($form, modelName) ->
      $http do
        method: $form.attr 'method'
        url: $form.attr 'action'
        data: $form.scope![modelName]
      .then successCallback, errorCallback

.directive 'remote' <[
       rails
]> ++ (rails) ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const remoteCtrl = $ctrls.0
    #
    const onSubmitHandler = !(event) ->
      # If $element.is 'a', it won't get the 'submit' event.
      # We can assume 'onSubmitHandler' will be triggered on 'form' $element.
      return if rails.confirmAction $attrs.confirm, event
      #
      remoteCtrl.submit $element, $attrs.remote
    #
    $element.on 'submit' onSubmitHandler
    $scope.$on '$destroy' !-> $element.off 'submit' onSubmitHandler

  require: <[remote]>
  restrict: 'A'
  controller: 'RailsRemoteFormCtrl'
  compile: (tElement, tAttrs) ->
    if tAttrs.$attr.remote is 'data-remote'
      postLinkFn
    else
      angular.noop


.directive 'method' <[
       rails
]> ++ (rails) ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const remoteCtrl = $ctrls.0 or new rails.noopRemoteFormCtrl
    
    const onClickHandler = !(event) ->
      return if rails.confirmAction $attrs.confirm, event
      
      const $form = rails.createMethodFormElement $attrs, $scope

      <-! remoteCtrl.submit $form, 'link' .then
      $form.scope!$destroy!
      $form.remove!

    $element.on 'click' onClickHandler
    $scope.$on '$destroy' !-> $element.off 'click' onClickHandler


  require: <[?remote]>
  restrict: 'A'
  compile: (tElement, tAttrs) ->
    if tAttrs.$attr.method is 'data-method'
      postLinkFn
    else
      angular.noop

