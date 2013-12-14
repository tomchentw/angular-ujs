const {noop, element} = angular

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

  remoteSubmit: ($form) ->
    const inputData = {}
    const inputsArray = $form.find 'input'
    for i from 0 til inputsArray.length
      const input = inputsArray.eq i
      name = input.attr 'name'
      name = name.replace /\[/g '.' .replace /\]/g '' if name.match /\[\S+\]/
      #
      switch input.attr 'type'
        when 'file'
          return false
        when 'checkbox'
          break unless input.0.checked
          #
          # @see http://apidock.com/rails/ActionView/Helpers/FormHelper/check_box
          #
          fallthrough
        default
          console.log name, input.val!
          $parse(name).assign(inputData, input.val!)

    $http do
      method: $form.attr 'method'
      url: $form.attr 'action'
      data: inputData

const remoteDirective = <[
       rails
]> ++ (rails) ->

  require: <[?confirm ?remote]>
  restrict: 'A'
  link: !($scope, $element, $attrs, $ctrls) ->
    const [confirmCtrl || noopConfirmCtrl, remoteCtrl] = $ctrls
    return unless $element.attr 'data-remote'
    #
    const onSubmitHandler = !(event) ->
      # If $element.is 'a', it won't get the 'submit' event.
      # We can assume 'onSubmitHandler' will be triggered on 'form' $element.
      rails.cancelActionOn event
      const answer = confirmCtrl.allowAction!
      return unless answer
      #
      remoteCtrl.submitForm $element, $attrs.type
    #
    $element.on 'submit' onSubmitHandler
    $scope.$on '$destroy' !-> $element.off 'submit' onSubmitHandler
  
  controller: <[
          rails
  ]> ++ !(rails) ->
    @submitForm = !($form) ->
      rails.remoteSubmit $form

const noopRemoteCtrl = do
  submitForm: !($form) ->
    $form.0.submit!

const methodDirective = <[
       $document  rails
]> ++ ($document, rails) ->

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
      const $form = element '<form method="post"></form>'
      $form.attr 'action' $attrs.href
      rails.appendCsrfInputTo $form
      const $method = element '<input type="hidden" name="_method">'
      $method.attr 'value' $attrs.method
      $form.append $method

      $document.find 'body' .append $form
      remoteCtrl.submitForm $form
    #
    $element.on 'click' onClickHandler
    $scope.$on '$destroy' !-> $element.off 'click' onClickHandler

angular.module 'rails.ujs' <[ng-rails-csrf]>
.directive 'confirm' confirmDirective
.factory 'rails' railsFactory
.directive 'remote' remoteDirective
.directive 'method' methodDirective
