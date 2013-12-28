(...) <-! describe 'module angular.ujs'
$compile = $rootScope = void

# beforeEach module 'angular.ujs'
beforeEach module 'angular.ujs'
beforeEach inject !(_$compile_, _$rootScope_) ->
  $compile    := _$compile_
  $rootScope  := _$rootScope_

it 'should start test' !(...) ->
  expect true .toBeTruthy!