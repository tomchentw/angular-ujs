(function(){
  var noop, element, confirmDirective, noopConfirmCtrl, railsFactory, remoteDirective, noopRemoteCtrl, methodDirective;
  noop = angular.noop, element = angular.element;
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
      },
      remoteSubmit: function($form){
        var inputData, inputsArray, i$, to$, i, input, name;
        inputData = {};
        inputsArray = $form.find('input');
        for (i$ = 0, to$ = inputsArray.length; i$ < to$; ++i$) {
          i = i$;
          input = inputsArray.eq(i);
          name = input.attr('name');
          if (name.match(/\[\S+\]/)) {
            name = name.replace(/\[/g, '.').replace(/\]/g, '');
          }
          switch (input.attr('type')) {
          case 'file':
            return false;
          case 'checkbox':
            if (!input[0].checked) {
              break;
            }
            // fallthrough
          default:
            console.log(name, input.val());
            $parse(name).assign(inputData, input.val());
          }
        }
        return $http({
          method: $form.attr('method'),
          url: $form.attr('action'),
          data: inputData
        });
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
        if (!$element.attr('data-remote')) {
          return;
        }
        onSubmitHandler = function(event){
          var answer;
          rails.cancelActionOn(event);
          answer = confirmCtrl.allowAction();
          if (!answer) {
            return;
          }
          remoteCtrl.submitForm($element, $attrs.type);
        };
        $element.on('submit', onSubmitHandler);
        $scope.$on('$destroy', function(){
          $element.off('submit', onSubmitHandler);
        });
      },
      controller: ['rails'].concat(function(rails){
        this.submitForm = function($form){
          rails.remoteSubmit($form);
        };
      })
    };
  });
  noopRemoteCtrl = {
    submitForm: function($form){
      $form[0].submit();
    }
  };
  methodDirective = ['$document', 'rails'].concat(function($document, rails){
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
          $form = element('<form method="post"></form>');
          $form.attr('action', $attrs.href);
          rails.appendCsrfInputTo($form);
          $method = element('<input type="hidden" name="_method">');
          $method.attr('value', $attrs.method);
          $form.append($method);
          $document.find('body').append($form);
          remoteCtrl.submitForm($form);
        };
        $element.on('click', onClickHandler);
        $scope.$on('$destroy', function(){
          $element.off('click', onClickHandler);
        });
      }
    };
  });
  angular.module('rails.ujs', ['ng-rails-csrf']).directive('confirm', confirmDirective).factory('rails', railsFactory).directive('remote', remoteDirective).directive('method', methodDirective);
}).call(this);
