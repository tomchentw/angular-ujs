/*! angular-ujs - v 0.4.10 - Sun Mar 09 2014 02:49:36 GMT+0800 (CST)
 * https://github.com/tomchentw/angular-ujs
 * Copyright (c) 2014 [tomchentw](https://github.com/tomchentw);
 * Licensed [MIT](http://tomchentw.mit-license.org)
 */
/*global angular:false*/
(function(){
  'use strict';
  function denyDefaultAction(event){
    event.preventDefault();
    event.stopPropagation();
  }
  angular.module('angular.ujs', []).factory('$getRailsCSRF', ['$document'].concat(function($document){
    return function(){
      var metas, i$, ref$, len$, meta;
      metas = {};
      for (i$ = 0, len$ = (ref$ = $document[0].querySelectorAll('meta[name^="csrf-"]')).length; i$ < len$; ++i$) {
        meta = ref$[i$];
        meta = angular.element(meta);
        metas[meta.attr('name')] = meta.attr('content');
      }
      return metas;
    };
  })).controller('noopRailsConfirmCtrl', function(){
    this.allowAction = function(){
      return true;
    };
    this.denyDefaultAction = denyDefaultAction;
  }).controller('RailsConfirmCtrl', ['$window', '$attrs'].concat(function($window, $attrs){
    this.allowAction = function(){
      var message;
      message = $attrs.confirm;
      return angular.isDefined(message) && $window.confirm(message);
    };
    this.denyDefaultAction = denyDefaultAction;
  })).controller('noopRailsRemoteFormCtrl', function(){
    this.submit = function($form){
      $form[0].submit();
      return {
        then: angular.noop
      };
    };
  }).controller('RailsRemoteFormCtrl', ['$scope', '$attrs', '$parse', '$http'].concat(function($scope, $attrs, $parse, $http){
    var successCallback, errorCallback;
    successCallback = function(response){
      $scope.$emit('rails:remote:success', response);
    };
    errorCallback = function(response){
      $scope.$emit('rails:remote:error', response);
    };
    this.submit = function($form){
      var targetScope, modelName, data, key, value, config, METHOD, own$ = {}.hasOwnProperty;
      targetScope = $form.scope();
      modelName = $attrs.remote;
      data = {};
      if (modelName + "" !== 'true') {
        $parse(modelName).assign(data, targetScope.$eval(modelName));
      } else {
        for (key in targetScope) if (own$.call(targetScope, key)) {
          value = targetScope[key];
          if (key === 'this' || key[0] === '$') {
            continue;
          }
          data[key] = value;
        }
      }
      config = {
        url: $form.attr('action'),
        method: $form.attr('method'),
        data: data
      };
      METHOD = data._method;
      if (METHOD !== 'GET' && METHOD !== 'POST') {
        config.headers = {
          'X-Http-Method-Override': METHOD
        };
      }
      return $http(config).then(successCallback, errorCallback);
    };
  })).directive('confirm', function(){
    function onClickHandler(confirmCtrl, event){
      if (!confirmCtrl.allowAction()) {
        confirmCtrl.denyDefaultAction(event);
      }
    }
    function postLinkFn($scope, $element, $attrs, $ctrls){
      var callback;
      callback = angular.bind(void 8, onClickHandler, $ctrls[0]);
      $element.on('click', callback);
      $scope.$on('$destroy', function(){
        $element.off('click', callback);
      });
    }
    return {
      restrict: 'A',
      require: ['confirm'],
      controller: 'RailsConfirmCtrl',
      compile: function(tElement, tAttrs){
        var $attr;
        $attr = tAttrs.$attr;
        if ($attr.confirm !== 'data-confirm' || $attr.remote === 'data-remote' || $attr.method === 'data-method') {
          return;
        }
        return postLinkFn;
      }
    };
  }).directive('remote', ['$controller'].concat(function($controller){
    function onSubmitHandler($element, $ctrls, event){
      $ctrls[1].denyDefaultAction(event);
      if ($ctrls[1].allowAction()) {
        $ctrls[0].submit($element);
      }
    }
    function postLinkFn($scope, $element, $attrs, $ctrls){
      var callback;
      if (!$ctrls[1]) {
        $ctrls[1] = $controller('noopRailsConfirmCtrl', {
          $scope: $scope
        });
      }
      callback = angular.bind(void 8, onSubmitHandler, $element, $ctrls);
      $element.on('submit', callback);
      $scope.$on('$destroy', function(){
        $element.off('submit', callback);
      });
    }
    return {
      require: ['remote', '?confirm'],
      restrict: 'A',
      controller: 'RailsRemoteFormCtrl',
      compile: function(tElement, tAttrs){
        if (tAttrs.$attr.remote !== 'data-remote') {
          return;
        }
        return postLinkFn;
      }
    };
  })).directive('method', ['$controller', '$compile', '$document', '$getRailsCSRF'].concat(function($controller, $compile, $document, $getRailsCSRF){
    function onClickHandler($scope, $attrs, $ctrls, event){
      var metaTags, childScope, $form;
      if ($ctrls[0].allowAction()) {
        $ctrls[0].denyDefaultAction(event);
      }
      metaTags = $getRailsCSRF();
      childScope = $scope.$new();
      $form = $compile("<form class=\"ng-hide\" method=\"POST\" action=\"" + $attrs.href + "\">\n  <input type=\"text\" name=\"_method\" ng-model=\"_method\">\n  <input type=\"text\" name=\"" + metaTags['csrf-param'] + "\" value=\"" + metaTags['csrf-token'] + "\">\n</form>")(childScope);
      $document.find('body').append($form);
      childScope.$apply(function(){
        childScope._method = $attrs.method;
      });
      $ctrls[1].submit($form).then(function(){
        childScope.$destroy();
        $form.remove();
      });
    }
    function postLinkFn($scope, $element, $attrs, $ctrls){
      var controllerArgs, callback;
      controllerArgs = {
        $scope: $scope,
        $attrs: $attrs
      };
      if (!$ctrls[0]) {
        $ctrls[0] = $controller('noopRailsConfirmCtrl', controllerArgs);
      }
      if (!$ctrls[1]) {
        $ctrls[1] = $controller('noopRailsRemoteFormCtrl', controllerArgs);
      }
      callback = angular.bind($ctrls, onClickHandler, $scope, $attrs, $ctrls);
      $element.on('click', callback);
      $scope.$on('$destroy', function(){
        $element.off('click', callback);
      });
    }
    return {
      require: ['?confirm', '?remote'],
      restrict: 'A',
      compile: function(tElement, tAttrs){
        if (tAttrs.$attr.method !== 'data-method') {
          return;
        }
        return postLinkFn;
      }
    };
  }));
}).call(this);
