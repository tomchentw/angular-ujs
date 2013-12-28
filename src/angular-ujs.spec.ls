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

  describe 'noopRemoteFormCtrl' !(...) ->
    it 'should be defined' !(...) ->
      expect railsService.noopRemoteFormCtrl .toBeDefined!

    it 'should be created with new' !(...) ->
      expect new railsService.noopRemoteFormCtrl .toBeDefined!

    it 'should return controller like RailsRemoteFormCtrl' !(...) ->
      const noopCtrl = new railsService.noopRemoteFormCtrl
      expect noopCtrl.submit .toBeDefined!
      
      const promise = noopCtrl.submit!
      expect promise.then .toBeDefined!

describe 'RailsRemoteFormCtrl' !(...) ->
  railsRemoteFormCtrl = $scope = void

  beforeEach inject !($controller) ->
    $scope              := $rootScope.$new!
    railsRemoteFormCtrl := $controller 'RailsRemoteFormCtrl' {$scope}

  afterEach !(...) ->
    $httpBackend.verifyNoOutstandingExpectation!
    $httpBackend.verifyNoOutstandingRequest!
    $scope.$destroy!

  it 'should have a submit method' !(...) ->
    expect railsRemoteFormCtrl.submit .toBeDefined!

  it 'should submit form using $http' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    
    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
    .respond 201

    $element = $compile('''
      <form method="POST" action="/users">
        <input ng-model="user.name" type="text">
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!

    railsRemoteFormCtrl.submit $element, 'user'
    $httpBackend.flush!

  it 'should submit complex form using $http' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const EXPECTED_EMAIL = 'developer@tomchentw.com'
    const EXPECTED_TOS = 'read'
    const EXPECTED_AGE = 18
    const EXPECTED_COMMIT = 'private'

    const EXPECTED_COLOR = 'green'
    const EXPECTED_DESC = 'angular-ujs is ready to work with your awesome project!!'
    const COLORS = <[red green blue]>

    $scope.colors = COLORS

    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
      email: EXPECTED_EMAIL
      tos: EXPECTED_TOS
      age: EXPECTED_AGE
      commit: EXPECTED_COMMIT
      color: EXPECTED_COLOR
      desc: EXPECTED_DESC
    .respond 201

    $element = $compile('''
      <form method="POST" action="/users">
        <input ng-model="user.name" type="text">
        <input ng-model="user.email" type="email">
        <input ng-model="user.tos" type="checkbox" ng-true-value="read">
        <input ng-model="user.age" type="number">

        <input ng-model="user.commit" value="public" type="radio">
        <input ng-model="user.commit" value="protected" type="radio">
        <input ng-model="user.commit" value="private" type="radio">

        <select ng-model="user.color" ng-options="color for color in colors"></select>
        <textarea ng-model="user.desc"></textarea>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    const inputs = $element.find 'input'
    inputs.eq 0 .val EXPECTED_NAME .change!
    inputs.eq 1 .val EXPECTED_EMAIL .change!
    inputs.2.click!
    inputs.eq 3 .val EXPECTED_AGE .change!
    inputs.6.click!
    
    $element.find 'select' .val COLORS.indexOf(EXPECTED_COLOR) .change!
    $element.find 'textarea' .val EXPECTED_DESC .change!
    $scope.$digest!

    railsRemoteFormCtrl.submit $element, 'user'
    $httpBackend.flush!

describe 'remote directive' !(...) ->
  $scope = void

  beforeEach inject !($controller) ->
    $scope       := $rootScope.$new!

  afterEach !(...) ->
    $httpBackend.verifyNoOutstandingExpectation!
    $httpBackend.verifyNoOutstandingRequest!
    $scope.$destroy!

  it "shouldn't activate without 'data-' prefix" !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const confirmSpy = spyOn window, 'confirm'
    
    $element = $compile('''
      <form method="POST" action="/users" remote="user">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!
    
    $element.on 'submit' !(event) ->
      expect event.defaultPrevented .toBeFalsy!
      event.preventDefault!
      event.stopPropagation!

    $element.find 'input' .eq 1 .click!

  it 'should submit using $http for form element' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const confirmSpy = spyOn window, 'confirm'
    
    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
    .respond 201

    $element = $compile('''
      <form method="POST" action="/users" data-remote="user">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!
    
    $element.find 'input' .eq 1 .click!
    $httpBackend.flush!
    expect confirmSpy .not.toHaveBeenCalled!



















