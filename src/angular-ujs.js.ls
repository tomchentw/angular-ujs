const {noop, element, isString} = angular

const confirmDirective = ->

  restrict: 'A'
  link: !(scope, element, attrs, confirmCtrl) ->
    confirmCtrl <<< attrs{confirm}

  controller: <[
          $window
  ]> ++ !($window) ->
    @allowAction = ->
      $window.confirm @confirm

const noopConfirmCtrl = do
  allowAction: -> true

const railsFactory = <[
       $document  $parse  $http
]> ++ ($document, $parse, $http) ->
  const metaTags = ->
    const metas       = {}
    const metasArray  = $document.find 'meta'
    for i from 0 til metasArray.length
      const meta = metasArray.eq i
      metas[meta.attr 'name'] = meta.attr 'content'
    metas

  metaTags: metaTags

  appendCsrfInputTo: !($form) ->
    const tags = metaTags!
    const $input = element '<input type="hidden"/>'
    $input.attr 'name' tags['csrf-param']
    $input.attr 'value' tags['csrf-token']
    $form.append $input

  cancelActionOn: !(event) ->
    event.preventDefault!
    event.stopPropagation!    

const remoteDirective = <[
       rails
]> ++ (rails) ->

  require: <[?confirm ?remote]>
  restrict: 'A'
  link: !($scope, $element, $attrs, $ctrls) ->
    const [confirmCtrl || noopConfirmCtrl, remoteCtrl] = $ctrls
    return unless $element.attr 'data-remote' |> isString
    #
    const onSubmitHandler = !(event) ->
      # If $element.is 'a', it won't get the 'submit' event.
      # We can assume 'onSubmitHandler' will be triggered on 'form' $element.
      rails.cancelActionOn event
      const answer = confirmCtrl.allowAction!
      return unless answer
      #
      remoteCtrl.submitForm $element, $attrs.remote
    #
    $element.on 'submit' onSubmitHandler
    $scope.$on '$destroy' !-> $element.off 'submit' onSubmitHandler
  
  controller: <[
          $scope  $http
  ]> ++ !($scope, $http) ->
    const successCallback = !(response) ->
      $scope.$emit 'rails:remote:success' response

    const errorCallback = !(response) ->
      $scope.$emit 'rails:remote:error' response

    @submitForm = ($form, modelName) ->
      $http do
        method: $form.attr 'method'
        url: $form.attr 'action'
        data:
          "#modelName": $scope[modelName]
      .then successCallback, errorCallback

const noopRemoteCtrl = do
  submitForm: ($form) ->
    $form.0.submit!
    #
    then: noop

const methodDirective = <[
       $document  $compile  rails
]> ++ ($document, $compile, rails) ->

  require: <[?confirm ?remote]>
  restrict: 'A'
  link: !($scope, $element, $attrs, $ctrls) ->
    const [confirmCtrl || noopConfirmCtrl, remoteCtrl || noopRemoteCtrl] = $ctrls
    return unless $element.attr 'data-method'
    #
    const onClickHandler = !(event) ->
      rails.cancelActionOn event
      const answer = confirmCtrl.allowAction!
      return unless answer
      #
      const $form = element '<form class="ng-hide" method="post"></form>'
      $form.attr 'action' $attrs.href
      rails.appendCsrfInputTo $form
      const $method = element '<input type="hidden" name="_method" ng-model="link._method">'
      $method.attr 'value' $attrs.method
      $form.append $method

      $compile($form)($scope.$new true)
      $document.find 'body' .append $form
      remoteCtrl.submitForm $form, 'link' .then !->
        $form.remove!
    #
    $element.on 'click' onClickHandler
    $scope.$on '$destroy' !-> $element.off 'click' onClickHandler

angular.module 'rails.ujs' <[ng-rails-csrf]>
.directive 'confirm' confirmDirective
.factory 'rails' railsFactory
.directive 'remote' remoteDirective
.directive 'method' methodDirective
