angular.module 'angular.ujs' <[]>
.factory 'rails' <[
       $window  $document  $parse  $http
]> ++ ($window, $document, $parse, $http) ->

  confirmAction: (message, $event) ->
    const answer = angular.isDefined message and $window.confirm message
    unless answer
      $event.preventDefault!
      $event.stopPropagation!
    answer

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
        data: $scope[modelName]
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


