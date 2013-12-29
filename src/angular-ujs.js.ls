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
 
  getMetaTags: getMetaTags

  createMethodFormElement: ($attrs, $scope) ->
    const metaTags = getMetaTags!
    const $form = $compile("""
      <form class="ng-hide" method="POST" action="#{ $attrs.href }">
        <input type="text" name="_method" ng-model="_method">
        <input type="text" name="#{ metaTags['csrf-param'] }" value="#{ metaTags['csrf-token'] }">
      </form>
    """)($scope.$new!)
    $document.find 'body' .append $form

    $form.find 'input' .eq 0 .val $attrs.method .change!
    $form

  noopConfirmCtrl: !->
    @allowAction = -> true

    @denyDefaultAction = !(event) ->
      event.preventDefault!
      event.stopPropagation!

  noopRemoteFormCtrl: !->
    @submit = ->
      then: angular.noop

.controller 'RailsConfirmCtrl' <[
        $window  rails
]> ++ !($window, rails) ->
  rails.noopConfirmCtrl ...
  
  @allowAction = ($attrs) ->
    const message = $attrs.confirm
    angular.isDefined message and $window.confirm message

.directive 'confirm' <[

]> ++ ->

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
       rails
]> ++ (rails) ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const [remoteCtrl, confirmCtrl || new rails.noopConfirmCtrl] = $ctrls
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
       rails
]> ++ (rails) ->

  const postLinkFn = !($scope, $element, $attrs, $ctrls) ->
    const [remoteCtrl || new rails.noopRemoteFormCtrl, confirmCtrl || new rails.noopConfirmCtrl] = $ctrls
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


  require: <[?remote ?confirm]>
  restrict: 'A'
  compile: (tElement, tAttrs) ->
    return if tAttrs.$attr.method isnt 'data-method'
    postLinkFn

