(function(){
  var noop, element, isString, confirmDirective, noopConfirmCtrl, railsFactory, remoteDirective, noopRemoteCtrl, methodDirective;
  noop = angular.noop, element = angular.element, isString = angular.isString;
  confirmDirective = function(){
    return {
      restrict: 'A',
      link: function(scope, element, attrs, confirmCtrl){
        confirmCtrl.confirm = attrs.confirm;
      },
      controller: ['$window'].concat(function($window){
        this.allowAction = function(){
          return $window.confirm(this.confirm);
        };
      })
    };
  };
  noopConfirmCtrl = {
    allowAction: function(){
      return true;
    }
  };
  railsFactory = ['$document', '$parse', '$http'].concat(function($document, $parse, $http){
    var metaTags;
    metaTags = function(){
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
      metaTags: metaTags,
      appendCsrfInputTo: function($form){
        var tags, $input;
        tags = metaTags();
        $input = element('<input type="hidden"/>');
        $input.attr('name', tags['csrf-param']);
        $input.attr('value', tags['csrf-token']);
        $form.append($input);
      },
      cancelActionOn: function(event){
        event.preventDefault();
        event.stopPropagation();
      }
    };
  });
  remoteDirective = ['rails'].concat(function(rails){
    return {
      require: ['?confirm', '?remote'],
      restrict: 'A',
      link: function($scope, $element, $attrs, $ctrls){
        var confirmCtrl, remoteCtrl, onSubmitHandler;
        confirmCtrl = $ctrls[0] || noopConfirmCtrl, remoteCtrl = $ctrls[1];
        if (!isString(
        $element.attr('data-remote'))) {
          return;
        }
        onSubmitHandler = function(event){
          var answer;
          rails.cancelActionOn(event);
          answer = confirmCtrl.allowAction();
          if (!answer) {
            return;
          }
          remoteCtrl.submitForm($element, $attrs.remote);
        };
        $element.on('submit', onSubmitHandler);
        $scope.$on('$destroy', function(){
          $element.off('submit', onSubmitHandler);
        });
      },
      controller: ['$scope', '$http'].concat(function($scope, $http){
        var successCallback, errorCallback;
        successCallback = function(response){
          $scope.$emit('rails:remote:success', response);
        };
        errorCallback = function(response){
          $scope.$emit('rails:remote:error', response);
        };
        this.submitForm = function($form, modelName){
          var ref$;
          return $http({
            method: $form.attr('method'),
            url: $form.attr('action'),
            data: (ref$ = {}, ref$[modelName + ""] = $scope[modelName], ref$)
          }).then(successCallback, errorCallback);
        };
      })
    };
  });
  noopRemoteCtrl = {
    submitForm: function($form){
      $form[0].submit();
      return {
        then: noop
      };
    }
  };
  methodDirective = ['$document', '$compile', 'rails'].concat(function($document, $compile, rails){
    return {
      require: ['?confirm', '?remote'],
      restrict: 'A',
      link: function($scope, $element, $attrs, $ctrls){
        var confirmCtrl, remoteCtrl, onClickHandler;
        confirmCtrl = $ctrls[0] || noopConfirmCtrl, remoteCtrl = $ctrls[1] || noopRemoteCtrl;
        if (!$element.attr('data-method')) {
          return;
        }
        onClickHandler = function(event){
          var answer, $form, $method;
          rails.cancelActionOn(event);
          answer = confirmCtrl.allowAction();
          if (!answer) {
            return;
          }
          $form = element('<form class="ng-hide" method="post"></form>');
          $form.attr('action', $attrs.href);
          rails.appendCsrfInputTo($form);
          $method = element('<input type="hidden" name="_method" ng-model="link._method">');
          $method.attr('value', $attrs.method);
          $form.append($method);
          $compile($form)($scope.$new(true));
          $document.find('body').append($form);
          remoteCtrl.submitForm($form, 'link').then(function(){
            $form.remove();
          });
        };
        $element.on('click', onClickHandler);
        $scope.$on('$destroy', function(){
          $element.off('click', onClickHandler);
        });
      }
    };
  });
  angular.module('angular.ujs', ['ng-rails-csrf']).directive('confirm', confirmDirective).factory('rails', railsFactory).directive('remote', remoteDirective).directive('method', methodDirective);
}).call(this);
