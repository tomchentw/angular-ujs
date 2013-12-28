(...) <-! describe 'module angular.ujs'
$compile = $rootScope = $document = $httpBackend = $sniffer = void

# beforeEach module 'angular.ujs'
beforeEach module 'angular.ujs'
beforeEach inject !(_$compile_, _$rootScope_, _$document_, _$httpBackend_, _$sniffer_) ->
  $compile      := _$compile_
  $rootScope    := _$rootScope_
  $document     := _$document_
  $httpBackend  := _$httpBackend_
  $sniffer      := _$sniffer_

const changeInputValueTo = !($input, value) ->
  $input.val value 
  $input.trigger if $sniffer.hasEvent 'input' then 'input' else 'change'
  $rootScope.$digest!

it 'should start test' !(...) ->
  expect true .toBeTruthy!


describe 'rails service' !(...) ->
  railsService = confirmSpy = mockEvent = void

  beforeEach inject !(rails) ->
    railsService  := rails
    confirmSpy    := spyOn window, 'confirm'
    mockEvent     := new Event 'click'

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

describe 'RailsRemoteFormCtrl' !(...) ->
  railsRemoteFormCtrl = $scope = void

  beforeEach inject !($controller ) ->
    $scope              := $rootScope.$new!
    railsRemoteFormCtrl := $controller 'RailsRemoteFormCtrl' {$scope}

  afterEach !(...) ->
    $httpBackend.verifyNoOutstandingExpectation!
    $httpBackend.verifyNoOutstandingRequest!

  it 'should have a submit method' !(...) ->
    expect railsRemoteFormCtrl.submit .toBeDefined!

  it 'should submit form using $http' !(...) ->
    $httpBackend.expectPOST '/users' do
      name: 'angular-ujs'
    .respond 201

    $element = $compile('''
      <form method="POST" action="/users">
        <input ng-model="user.name" type="text">
      </form>
    ''')($scope)

    $element.find 'input' .eq 0 |> changeInputValueTo _, 'angular-ujs'
    railsRemoteFormCtrl.submit $element, 'user'
    $httpBackend.flush!























