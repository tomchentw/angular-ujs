(function(){
  angular.module('angular.ujs', []).factory('rails', ['$window', '$document', '$compile'].concat(function($window, $document, $compile){
    var getMetaTags;
    getMetaTags = function(){
      var metas, metasArray, i$, to$, i, meta;
      metas = {};
      metasArray = $document.find('meta');
      for (i$ = 0, to$ = metasArray.length; i$ < to$; ++i$) {
        i = i$;
        meta = metasArray.eq(i);
        metas[meta.attr('name')] = meta.attr('content');
      }
      return metas;
    };
    return {
      getMetaTags: getMetaTags,
      createMethodFormElement: function($attrs, $scope){
        var metaTags, childScope, $form;
        metaTags = getMetaTags();
        childScope = $scope.$new();
        $form = $compile("<form class=\"ng-hide\" method=\"POST\" action=\"" + $attrs.href + "\">\n  <input type=\"text\" name=\"_method\" ng-model=\"_method\">\n  <input type=\"text\" name=\"" + metaTags['csrf-param'] + "\" value=\"" + metaTags['csrf-token'] + "\">\n</form>")(childScope);
        $document.find('body').append($form);
        childScope.$apply(function(){
          childScope._method = $attrs.method;
        });
        return $form;
      },
      noopConfirmCtrl: function(){
        this.allowAction = function(){
          return true;
        };
        this.denyDefaultAction = function(event){
          event.preventDefault();
          event.stopPropagation();
        };
      },
      noopRemoteFormCtrl: function(){
        this.submit = function($form){
          $form[0].submit();
          return {
            then: angular.noop
          };
        };
      }
    };
  })).controller('RailsConfirmCtrl', ['$window', 'rails'].concat(function($window, rails){
    rails.noopConfirmCtrl.apply(this, arguments);
    this.allowAction = function($attrs){
      var message;
      message = $attrs.confirm;
      return angular.isDefined(message) && $window.confirm(message);
    };
  })).directive('confirm', [].concat(function(){
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
      compile: function(tElement, tAttrs){
        var $attr;
        $attr = tAttrs.$attr;
        if ($attr.confirm !== 'data-confirm' || $attr.remote === 'data-remote' || $attr.method === 'data-method') {
          return;
        }
        return postLinkFn;
      }
    };
  })).controller('RailsRemoteFormCtrl', ['$scope', '$parse', '$http'].concat(function($scope, $parse, $http){
    var successCallback, errorCallback;
    successCallback = function(response){
      $scope.$emit('rails:remote:success', response);
    };
    errorCallback = function(response){
      $scope.$emit('rails:remote:error', response);
    };
    this.submit = function($form, modelName){
      var targetScope, data, key, value, own$ = {}.hasOwnProperty;
      targetScope = $form.scope();
      data = {};
      if (modelName + "" !== 'true') {
        console.log('parsing modelName', modelName);
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
      console.log(data, modelName, modelName === true);
      return $http({
        method: $form.attr('method'),
        url: $form.attr('action'),
        data: data
      }).then(successCallback, errorCallback);
    };
  })).directive('remote', ['rails'].concat(function(rails){
    var postLinkFn;
    postLinkFn = function($scope, $element, $attrs, $ctrls){
      var remoteCtrl, confirmCtrl, onSubmitHandler;
      remoteCtrl = $ctrls[0], confirmCtrl = $ctrls[1] || new rails.noopConfirmCtrl;
      onSubmitHandler = function(event){
        if (confirmCtrl.allowAction($attrs)) {
          confirmCtrl.denyDefaultAction(event);
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
  })).directive('method', ['rails'].concat(function(rails){
    var postLinkFn;
    postLinkFn = function($scope, $element, $attrs, $ctrls){
      var remoteCtrl, confirmCtrl, onClickHandler;
      remoteCtrl = $ctrls[0] || new rails.noopRemoteFormCtrl, confirmCtrl = $ctrls[1] || new rails.noopConfirmCtrl;
      console.log(remoteCtrl);
      onClickHandler = function(event){
        var $form;
        console.log('onClickHandler');
        if (confirmCtrl.allowAction($attrs)) {
          confirmCtrl.denyDefaultAction(event);
        }
        $form = rails.createMethodFormElement($attrs, $scope);
        console.log('before remoteCtrl.submit');
        remoteCtrl.submit($form, true).then(function(){
          $form.scope().$destroy();
          $form.remove();
        });
      };
      console.log('setup onClickHandler');
      $element.on('click', onClickHandler);
      $scope.$on('$destroy', function(){
        $element.off('click', onClickHandler);
      });
    };
    return {
      require: ['?remote', '?confirm'],
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
