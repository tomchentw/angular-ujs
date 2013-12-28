(...) <-! describe 'module angular.ujs'
$compile = $rootScope = void

# beforeEach module 'angular.ujs'
beforeEach module 'angular.ujs'
beforeEach inject !(_$compile_, _$rootScope_) ->
  $compile    := _$compile_
  $rootScope  := _$rootScope_

it 'should start test' !(...) ->
  expect true .toBeTruthy!


describe 'rails service' !(...) ->
  railsService = confirmSpy = mockEvent = void

  beforeEach inject !(rails) ->
    railsService := rails
    confirmSpy := spyOn window, 'confirm'
    mockEvent := new Event 'click'

  describe 'confirmAction' !(...) ->
    const MESSAGE = 'iMESSAGE'

    it 'should trigger window.confirm' !(...) ->
      confirmSpy.andReturn true
      railsService.confirmAction MESSAGE, mockEvent
      expect confirmSpy .toHaveBeenCalled!

    it 'should return value of calling window.confirm' !(...) ->
      const TRUTHY_STRING = 'success'
      confirmSpy.andReturn TRUTHY_STRING
      expect railsService.confirmAction(MESSAGE, mockEvent) .toEqual TRUTHY_STRING

    it 'should allow falsy value returned by calling window.confirm' !(...) ->
      confirmSpy.andReturn null
      expect railsService.confirmAction(MESSAGE, mockEvent) .toBeFalsy!

