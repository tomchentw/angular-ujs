(...) <-! describe 'module angular.ujs'
$compile = $rootScope = $document = $httpBackend = $sniffer = void

beforeEach module 'angular.ujs'
beforeEach inject !(_$compile_, _$rootScope_, _$document_, _$httpBackend_, _$sniffer_) ->
  $compile      := _$compile_
  $rootScope    := _$rootScope_
  $document     := _$document_
  $httpBackend  := _$httpBackend_
  $sniffer      := _$sniffer_

afterEach !(...) ->
  $httpBackend.verifyNoOutstandingExpectation!
  $httpBackend.verifyNoOutstandingRequest!
  $rootScope.$destroy!

it 'should start test' !(...) ->
  expect true .toBeTruthy!

describe '$getRailsCSRF conditional inject' !(...) ->
  const MOCK_META_TAGS = '''
    <meta content="authenticity_token" name="csrf-param">
    <meta content="qwertyuiopasdfghjklzxcvbnm=" name="csrf-token">
  '''

  it 'should return csrf meta tags' inject !($getRailsCSRF) ->
    $document.find 'head' .append MOCK_META_TAGS
    const metaTags = $getRailsCSRF!

    expect metaTags['csrf-param'] .toBe 'authenticity_token'
    expect metaTags['csrf-token'] .toBe 'qwertyuiopasdfghjklzxcvbnm='

describe 'noopRailsConfirmCtrl' !(...) ->
  noopCtrl = void

  beforeEach inject !($controller) ->
    noopCtrl := $controller 'noopRailsConfirmCtrl' $scope: $rootScope

  it 'should be like RailsConfirmCtrl' !(...) ->    
    expect noopCtrl.allowAction .toBeDefined!
    expect noopCtrl.denyDefaultAction .toBeDefined!
    expect noopCtrl.allowAction! .toBeTruthy!

  it 'should supress event when denyDefaultAction called' !(...) ->
    const event = $.Event 'click'
    noopCtrl.denyDefaultAction event

    expect event.isDefaultPrevented! .toBeTruthy!
    expect event.isPropagationStopped! .toBeTruthy!

describe 'RailsConfirmCtrl' !(...) ->
  railsConfirmCtrl = confirmSpy = void

  beforeEach inject !($controller) ->
    railsConfirmCtrl  := $controller 'RailsConfirmCtrl' $scope: $rootScope
    confirmSpy        := spyOn window, 'confirm'

  it 'should have a denyDefaultAction method' !(...) ->
    expect railsConfirmCtrl.denyDefaultAction .toBeDefined!

  it 'should have a allowAction method' !(...) ->
    expect railsConfirmCtrl.allowAction .toBeDefined!

  it "shouldn't allow action when message missing" !(...) ->
    const $attrs = do
      confirm: void

    expect railsConfirmCtrl.allowAction($attrs) .toBeFalsy!
    expect confirmSpy .not.toHaveBeenCalled!

  it "shouldn't allow action when cancel confirm" !(...) ->
    confirmSpy := confirmSpy.andReturn false
    const $attrs = do
      confirm: 'iMessage'

    expect railsConfirmCtrl.allowAction($attrs) .toBeFalsy!
    expect confirmSpy .toHaveBeenCalled!

  it 'should allow action when message provided and confirmed' !(...) ->
    confirmSpy := confirmSpy.andReturn true
    const $attrs = do
      confirm: 'iMessage'

    expect railsConfirmCtrl.allowAction($attrs) .toBeTruthy!
    expect confirmSpy .toHaveBeenCalled!

describe 'noopRailsRemoteFormCtrl' !(...) ->
  noopCtrl = void

  beforeEach inject !($controller) ->
    noopCtrl := $controller 'noopRailsRemoteFormCtrl' $scope: $rootScope

  it 'should submit form naively' !(...) ->
    expect noopCtrl.submit .toBeDefined!

    const $form = [jasmine.createSpyObj 'form', <[ submit ]>]
    const promise = noopCtrl.submit $form
    expect $form.0.submit .toHaveBeenCalled!
    expect promise.then .toBeDefined!

describe 'RailsRemoteFormCtrl' !(...) ->
  railsRemoteFormCtrl = void

  beforeEach inject !($controller) ->
    railsRemoteFormCtrl := $controller 'RailsRemoteFormCtrl' $scope: $rootScope

  it 'should have a submit method' !(...) ->
    expect railsRemoteFormCtrl.submit .toBeDefined!

  it 'should submit simple form using $http' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    
    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users">
        <input ng-model="name" type="text">
      </form>
    ''')($rootScope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $rootScope.$digest!

    railsRemoteFormCtrl.submit $element, true
    $httpBackend.flush!
    $element.remove!

  it 'should submit complex, named form using $http' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const EXPECTED_EMAIL = 'developer@tomchentw.com'
    const EXPECTED_TOS = 'read'
    const EXPECTED_AGE = 18
    const EXPECTED_COMMIT = 'private'

    const EXPECTED_COLOR = 'green'
    const EXPECTED_DESC = 'angular-ujs is ready to work with your awesome project!!'
    const COLORS = <[red green blue]>

    $rootScope.colors = COLORS

    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
        email: EXPECTED_EMAIL
        tos: EXPECTED_TOS
        age: EXPECTED_AGE
        commit: EXPECTED_COMMIT
        color: EXPECTED_COLOR
        desc: EXPECTED_DESC
    .respond 201

    const $element = $compile('''
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
    ''')($rootScope)
    $document.find 'body' .append $element

    const inputs = $element.find 'input'
    inputs.eq 0 .val EXPECTED_NAME .change!
    inputs.eq 1 .val EXPECTED_EMAIL .change!
    inputs.2.click!
    inputs.eq 3 .val EXPECTED_AGE .change!
    inputs.6.click!
    
    $element.find 'select' .val COLORS.indexOf(EXPECTED_COLOR) .change!
    $element.find 'textarea' .val EXPECTED_DESC .change!
    $rootScope.$digest!

    railsRemoteFormCtrl.submit $element, 'user'
    $httpBackend.flush!
    $element.remove!

describe 'confirm directive' !(...) ->
  confirmSpy = void
  
  beforeEach !(...) ->
    confirmSpy := spyOn window, 'confirm'

  it 'should show confirm dialog' !(...) ->
    const $element = $compile('''
      <button data-confirm="confirm..."></button>
    ''')($rootScope)

    $document.find 'body' .append $element
    $element.click!

    expect confirmSpy .toHaveBeenCalled!

  it 'should allow confirm' !(...) ->
    confirmSpy.andReturn true

    const $element = $compile('''
      <button data-confirm="confirm..."></button>
    ''')($rootScope)

    $document.find 'body' .append $element
    $element.click!

    expect confirmSpy .toHaveBeenCalled!

describe 'remote directive' !(...) ->
  const EXPECTED_NAME = 'angular-ujs'

  it 'should submit using $http for form element' !(...) ->
    const confirmSpy = spyOn window, 'confirm'
    
    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users" data-remote="true">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($rootScope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $rootScope.$digest!
    
    $element.find 'input' .eq 1 .click!
    $httpBackend.flush!
    
    expect confirmSpy .not.toHaveBeenCalled!

  it 'should submit with named data-remote' !(...) ->
    const confirmSpy = spyOn window, 'confirm'
    
    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users" data-remote="user">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($rootScope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $rootScope.$digest!
    
    $element.find 'input' .eq 1 .click!
    $httpBackend.flush!


    expect confirmSpy .not.toHaveBeenCalled!

  it 'should work with confirm directive when disallow dialog' !(...) ->
    const confirmSpy = spyOn window, 'confirm' .andReturn false
    const $element = $compile('''
      <form method="POST" action="/users" data-confirm="Are u sure?" data-remote="true">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($rootScope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $rootScope.$digest!
    
    $element.find 'input' .eq 1 .click!
    
    expect confirmSpy .toHaveBeenCalled!

  it 'should work with confirm directive' !(...) ->
    const confirmSpy = spyOn window, 'confirm' .andReturn true
    
    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users" data-confirm="Are u sure?" data-remote="true">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($rootScope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $rootScope.$digest!
    
    $element.find 'input' .eq 1 .click!

    expect confirmSpy .toHaveBeenCalled!

    $httpBackend.flush!

describe 'method directive with remote directive' !(...) ->
  it 'should submit and emit success with remote form' !(...) ->
    response = false
    $httpBackend.expectPOST '/users/sign_out' do
      _method: 'DELETE'
    .respond 201

    const $element = $compile('''
      <a href="/users/sign_out" data-method="DELETE" data-remote="true">SignOut</a>
    ''')($rootScope)
    $document.find 'body' .append $element

    $rootScope.$on 'rails:remote:success' !->
      response := true

    $element.click!
    $httpBackend.flush!
    $rootScope.$digest!
    
    expect response .toBeTruthy!
    
  it 'should submit and emit error with remote form' !(...) ->
    error = false
    $httpBackend.expectPOST '/users/sign_out' do
      _method: 'PUT'
    .respond 404

    const $element = $compile('''
      <a href="/users/sign_out" data-method="PUT" data-remote="true">SignOut</a>
    ''')($rootScope)
    $document.find 'body' .append $element

    $rootScope.$on 'rails:remote:error' !->
      error := true

    $element.click!
    $httpBackend.flush!
    $rootScope.$digest!
    
    expect error .toBeTruthy!

  it 'should work with confirm and remote form' !(...) ->
    response = false
    spyOn window, 'confirm' .andReturn true
    $httpBackend.expectPOST '/users/sign_out' do
      _method: 'DELETE'
    .respond 201

    const $element = $compile('''
      <a href="/users/sign_out" data-method="DELETE" data-remote="true" data-confirm="Are u sure?">SignOut</a>
    ''')($rootScope)
    $document.find 'body' .append $element

    $rootScope.$on 'rails:remote:success' !->
      response := true

    $element.click!
    $httpBackend.flush!
    $rootScope.$digest!

    expect response .toBeTruthy!










