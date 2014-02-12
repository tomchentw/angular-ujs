# angular-ujs

Unobtrusive scripting for AngularJS ( without jQuery dependency )


## Utils

```livescript
/*global angular:false*/
'use strict'

!function denyDefaultAction(event)
  event.preventDefault!
  event.stopPropagation!
```


## AngularJS Module definition

```livescript
angular.module 'angular.ujs' <[
]>
```


### $getRailsCSRF helper function

Extract function from csrf token in html/head.

```livescript
.factory '$getRailsCSRF' <[
       $document
]> ++ ($document) -> 
  ->
    const metas       = {}
    for meta in $document.0.querySelectorAll 'meta[name^="csrf-"]'
      meta = angular.element meta
      metas[meta.attr 'name'] = meta.attr 'content'
    metas
```

### noopRailsConfirmCtrl

**Null Object**

Just allows the event's default action to be performed.

```livescript
.controller 'noopRailsConfirmCtrl' !->
  @allowAction = -> true

  @denyDefaultAction = denyDefaultAction
```

### RailsConfirmCtrl

Confirm logic here:

```livescript
.controller 'RailsConfirmCtrl' <[
        $window  $attrs
]> ++ !($window, $attrs) ->
```

* allowAction: show a confirm from browser and return user's choice.  
Confirm popup will be fired only when confirm message is defined (via $attr).

```livescript
  @allowAction = ->
    const message = $attrs.confirm
    angular.isDefined message and $window.confirm message
```

* denyDefaultAction: just use the default implementation

```livescript
  @denyDefaultAction = denyDefaultAction
```

### noopRailsConfirmCtrl

**Null Object**

Just submit the form with plain old dom submit api.

```livescript
.controller 'noopRailsRemoteFormCtrl' !->
  @submit = ($form) ->
    $form.0.submit!
    #
    then: angular.noop
```

### RailsRemoteFormCtrl

Remote logic here:

```livescript
.controller 'RailsRemoteFormCtrl' <[
        $scope  $attrs  $parse  $http
]> ++ !($scope, $attrs, $parse, $http) ->
```

#### Emit event from $scope when remote form responses/failure:

* success: `rails:remote:success` event
* failure: `rails:remote:error` event

```livescript
    !function successCallback (response)
      $scope.$emit 'rails:remote:success' response

    !function errorCallback (response)
      $scope.$emit 'rails:remote:error' response
```

#### Submit remote form using $http. Will capture:

* url: `action` attribute
* method: `method` attribute
* data: `remote` attribute with two cases:

##### `true`: will use the scope (strip key started with `$`) itself

##### a String: will user `$scope.$eval(string)` to retrieve data

```livescript
    @submit = ($form) ->
      const targetScope = $form.scope!
      const modelName = $attrs.remote
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
```

# Bug Here

You should explicitly override method with `X-Http-Method-Override` so that rails 4 will intercept that (such as `PUT` method).

## [source](http://stackoverflow.com/a/1935237/1458162)

```livescript
      const METHOD = data._method
      if METHOD isnt 'GET' and METHOD isnt 'POST'
        config.headers = 'X-Http-Method-Override': METHOD
      #
      $http config .then successCallback, errorCallback
```

### confirm directive

These logic (in `angular-ujs` module) will only apply to explicity defined data attribute by rails. Any other attribute (eg. x-confirm, confirm, ...) will have no effect.

```livescript
.directive 'confirm' ->
```

Define a bound handler

```livescript
  !function onClickHandler (confirmCtrl, event)
    confirmCtrl.denyDefaultAction event unless confirmCtrl.allowAction!
```

Bind click handler with the controller

```livescript
  !function postLinkFn ($scope, $element, $attrs, $ctrls)
    const callback = angular.bind void, onClickHandler, $ctrls.0
    
    $element.on 'click' callback
    $scope.$on '$destroy' !-> $element.off 'click' callback
```

Directive Definition Object

```livescript
  restrict: 'A'
  require: <[ confirm ]>
  controller: 'RailsConfirmCtrl'
  compile: (tElement, tAttrs) ->
    const {$attr} = tAttrs
```

Read non-normalized attribute name from tAttrs.
Return undefined in compile function will skip the link phase for this directive (and thus have no effect).

```livescript
    return if $attr.confirm isnt 'data-confirm' or $attr.remote is 'data-remote' or $attr.method is 'data-method'
    postLinkFn
```

### remote directive

```livescript
.directive 'remote' <[
       $controller
]> ++ ($controller) ->

  !function onSubmitHandler ($element, $ctrls, event)
    $ctrls.1.denyDefaultAction event

    if $ctrls.1.allowAction!
      $ctrls.0.submit $element
```

Bind submit handler with controllers.
The remote directive can be used in anchor tag, but there's no need to check template's tag name since it will never fire the submit event.

```livescript
  !function postLinkFn ($scope, $element, $attrs, $ctrls)
    $ctrls.1 = $controller 'noopRailsConfirmCtrl' {$scope} unless $ctrls.1

    const callback = angular.bind void, onSubmitHandler, $element, $ctrls

    $element.on 'submit' callback
    $scope.$on '$destroy' !-> $element.off 'submit' callback
```

Directive Definition Object

```livescript
  require: <[ remote ?confirm ]>
  restrict: 'A'
  controller: 'RailsRemoteFormCtrl'
  compile: (tElement, tAttrs) ->
    return if tAttrs.$attr.remote isnt 'data-remote'
    postLinkFn
```

### method directive

```livescript
.directive 'method' <[
       $controller  $compile  $document  $getRailsCSRF
]> ++ ($controller, $compile, $document, $getRailsCSRF) ->

  !function onClickHandler ($scope, $attrs, $ctrls, event)
    $ctrls.0.denyDefaultAction event if $ctrls.0.allowAction!
```

For simple link that submit non-GET request, we need to create a native form for it, and thus csrf token is required. The form is hidden by `ng-hide` class.

```livescript
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
```

If this is combined with remote directive, we need to remove the form and child scope to prevent memory leak. Otherwise, page is redirected.

```livescript
    <-! $ctrls.1.submit $form .then
    childScope.$destroy!
    $form.remove!

  !function postLinkFn ($scope, $element, $attrs, $ctrls)
    const controllerArgs = {$scope, $attrs}
```

Inject null controllers if they're not provided

```livescript
    $ctrls.0 = $controller 'noopRailsConfirmCtrl' controllerArgs unless $ctrls.0
    $ctrls.1 = $controller 'noopRailsRemoteFormCtrl' controllerArgs unless $ctrls.1
    
    const callback = angular.bind $ctrls, onClickHandler, $scope, $attrs, $ctrls
    
    $element.on 'click' callback
    $scope.$on '$destroy' !-> $element.off 'click' callback


  require: <[ ?confirm ?remote ]>
  restrict: 'A'
  compile: (tElement, tAttrs) ->
    return if tAttrs.$attr.method isnt 'data-method'
    postLinkFn
```
