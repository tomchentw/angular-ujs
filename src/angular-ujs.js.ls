angular.module 'angular.ujs' <[]>
.factory 'rails' <[
       $window  $document  $parse  $http
]> ++ ($window, $document, $parse, $http) ->

  confirmAction: (message, $event) ->
    const answer = $window.confirm message || ''
    unless answer
      $event.preventDefault!
      $event.stopPropagation!
    answer

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