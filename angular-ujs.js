/*! angular-ujs - v 0.4.13 - Wed Apr 23 2014 21:24:18 GMT+0800 (CST)
 * https://github.com/tomchentw/angular-ujs
 * Copyright (c) 2014 [tomchentw](https://github.com/tomchentw);
 * Licensed [MIT](http://tomchentw.mit-license.org)
 */
/*global angular:false*/
(function(angular, bind){
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
  })).controller('noopRailsConfirmCtrl', (function(){
    var prototype = constructor.prototype;
    prototype.allowAction = function(){
      return true;
    };
    prototype.denyDefaultAction = denyDefaultAction;
    function constructor(){}
    return constructor;
  }())).controller('RailsConfirmCtrl', (function(){
    var prototype = constructor.prototype;
    prototype.allowAction = function(){
      var message;
      message = this.$attrs.confirm;
      return angular.isDefined(message) && this.$window.confirm(message);
    };
    prototype.denyDefaultAction = denyDefaultAction;
    constructor.$inject = ['$window', '$attrs'];
    function constructor($window, $attrs){
      this.$window = $window;
      this.$attrs = $attrs;
    }
    return constructor;
  }())).controller('noopRailsRemoteFormCtrl', (function(){
    var prototype = constructor.prototype;
    prototype.submit = function($form){
      $form[0].submit();
      return {
        then: angular.noop
      };
    };
    function constructor(){}
    return constructor;
  }())).controller('RailsRemoteFormCtrl', (function(){
    var prototype = constructor.prototype;
    prototype.submit = function($form){
      var targetScope, modelName, data, key, value, config, METHOD, own$ = {}.hasOwnProperty;
      targetScope = $form.scope();
      modelName = this.$attrs.remote;
      data = {};
      if (modelName + "" !== 'true') {
        this.$parse(modelName).assign(data, targetScope.$eval(modelName));
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
      return this.$http(config).then(this.successCallback, this.errorCallback);
    };
    prototype.successCallback = function(response){
      this.$scope.$emit('rails:remote:success', response);
    };
    prototype.errorCallback = function(response){
      this.$scope.$emit('rails:remote:error', response);
    };
    constructor.$inject = ['$scope', '$attrs', '$parse', '$http'];
    function constructor($scope, $attrs, $parse, $http){
      this.$scope = $scope;
      this.$attrs = $attrs;
      this.$parse = $parse;
      this.$http = $http;
      this.successCallback = bind(this, this.successCallback);
      this.errorCallback = bind(this, this.errorCallback);
    }
    return constructor;
  }())).directive('confirm', function(){
    function onClickHandler(confirmCtrl, event){
      if (!confirmCtrl.allowAction()) {
        confirmCtrl.denyDefaultAction(event);
      }
    }
    function postLinkFn($scope, $element, $attrs, $ctrls){
      var callback;
      callback = bind(void 8, onClickHandler, $ctrls[0]);
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
      callback = bind(void 8, onSubmitHandler, $element, $ctrls);
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
      callback = bind($ctrls, onClickHandler, $scope, $attrs, $ctrls);
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
}.call(this, angular, angular.bind));