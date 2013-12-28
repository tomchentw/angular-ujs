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