/*! angular-ujs - v 0.4.4 - Thu Jan 16 2014 01:37:30 GMT+0800 (CST)
 * https://github.com/tomchentw/angular-ujs
 * Copyright (c) 2014 [tomchentw](https://github.com/tomchentw/);
 * Licensed [MIT](http://tomchentw.mit-license.org/)
 *//*global angular:false*/
(function(){
  'use strict';
  var denyDefaultAction;
  denyDefaultAction = function(event){
    event.preventDefault();
    event.stopPropagation();
  };
  angular.module('angular.ujs', []).config(['$provide', '$injector'].concat(function($provide, $injector){
    var NAME;
    NAME = '$getRailsCSRF';
    if ($injector.has(NAME)) {
      return;
    }
    /*
     * Maybe provided in `ng-rails-csrf`
     */
    $provide.factory(NAME, ['$document'].concat(function($document){
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
    }));
  })).controller('noopRailsConfirmCtrl', function(){
    this.allowAction = function(){
      return true;
    };
    this.denyDefaultAction = denyDefaultAction;
  }).controller('noopRailsRemoteFormCtrl', function(){
    this.submit = function($form){
      $form[0].submit();
      return {
        then: angular.noop
      };
    };
  }).controller('RailsConfirmCtrl', ['$window'].concat(function($window){
    this.allowAction = function($attrs){
      var message;
      message = $attrs.confirm;
      return angular.isDefined(message) && $window.confirm(message);
    };
    this.denyDefaultAction = denyDefaultAction;
  })).directive('confirm', function(){
    var postLinkFn;
    postLinkFn = function($scope, $element, $attrs, $ctrls){
      var confirmCtrl, onClickHandler;
      confirmCtrl = $ctrls[0];
      onClickHandler = function(event){
        if (!confirmCtrl.allowAction($attrs)) {
          confirmCtrl.denyDefaultAction(event);
        }
      };
      $element.on('click', onClickHandler);
      $scope.$on('$destroy', function(){
        $element.off('click', onClickHandler);
      });
    };
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
  }).controller('RailsRemoteFormCtrl', ['$scope', '$parse', '$http'].concat(function($scope, $parse, $http){
    var successCallback, errorCallback;
    successCallback = function(response){
      $scope.$emit('rails:remote:success', response);
    };
    errorCallback = function(response){
      $scope.$emit('rails:remote:error', response);
    };
    this.submit = function($form, modelName){
      var targetScope, data, key, value, config, METHOD, own$ = {}.hasOwnProperty;
      targetScope = $form.scope();
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
  })).directive('remote', ['$controller'].concat(function($controller){
    var postLinkFn;
    postLinkFn = function($scope, $element, $attrs, $ctrls){
      var remoteCtrl, confirmCtrl, onSubmitHandler;
      remoteCtrl = $ctrls[0], confirmCtrl = $ctrls[1] || $controller('noopRailsConfirmCtrl', {
        $scope: $scope
      });
      onSubmitHandler = function(event){
        confirmCtrl.denyDefaultAction(event);
        if (!confirmCtrl.allowAction($attrs)) {
          return;
        }
        remoteCtrl.submit($element, $attrs.remote);
      };
      $element.on('submit', onSubmitHandler);
      $scope.$on('$destroy', function(){
        $element.off('submit', onSubmitHandler);
      });
    };
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
    var postLinkFn;
    postLinkFn = function($scope, $element, $attrs, $ctrls){
      var confirmCtrl, remoteCtrl, onClickHandler;
      confirmCtrl = $ctrls[0] || $controller('noopRailsConfirmCtrl', {
        $scope: $scope
      }), remoteCtrl = $ctrls[1] || $controller('noopRailsRemoteFormCtrl', {
        $scope: $scope
      });
      onClickHandler = function(event){
        var metaTags, childScope, $form;
        if (confirmCtrl.allowAction($attrs)) {
          confirmCtrl.denyDefaultAction(event);
        }
        metaTags = $getRailsCSRF();
        childScope = $scope.$new();
        $form = $compile("<form class=\"ng-hide\" method=\"POST\" action=\"" + $attrs.href + "\">\n  <input type=\"text\" name=\"_method\" ng-model=\"_method\">\n  <input type=\"text\" name=\"" + metaTags['csrf-param'] + "\" value=\"" + metaTags['csrf-token'] + "\">\n</form>")(childScope);
        $document.find('body').append($form);
        childScope.$apply(function(){
          childScope._method = $attrs.method;
        });
        remoteCtrl.submit($form, true).then(function(){
          childScope.$destroy();
          $form.remove();
        });
      };
      $element.on('click', onClickHandler);
      $scope.$on('$destroy', function(){
        $element.off('click', onClickHandler);
      });
    };
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
