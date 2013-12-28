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

afterEach !(...) ->
  $httpBackend.verifyNoOutstandingExpectation!
  $httpBackend.verifyNoOutstandingRequest!

it 'should start test' !(...) ->
  expect true .toBeTruthy!


describe 'rails service' !(...) ->
  const MOCK_META_TAGS = '''
    <meta content="authenticity_token" name="csrf-param">
    <meta content="qwertyuiopasdfghjklzxcvbnm=" name="csrf-token">
  '''

  railsService = void

  beforeEach inject !(rails) ->
    railsService  := rails


  const appendMetaTags = (template || MOCK_META_TAGS) ->
    const $meta = angular.element template
    $document.find 'head' .append $meta
    $meta

  describe 'getMetaTags' !(...) ->
    
    it 'should return object' !(...) ->
      expect typeof! railsService.getMetaTags! .toBe 'Object'

    it 'should return added meta tags' !(...) ->
      const $meta = appendMetaTags '<meta content="authenticity_token" name="csrf-param">'
      const metaTags = railsService.getMetaTags!

      expect metaTags['csrf-param'] .toBe 'authenticity_token'

    it 'should return csrf meta tags' !(...) ->
      const $meta = appendMetaTags!
      const metaTags = railsService.getMetaTags!

      expect metaTags['csrf-param'] .toBe 'authenticity_token'
      expect metaTags['csrf-token'] .toBe 'qwertyuiopasdfghjklzxcvbnm='

  describe 'createMethodFormElement' !(...) ->
    const $attrs = do
      href: '/admin/login'
      method: 'PUT'

    it 'should return compiled form element' !(...) ->
      appendMetaTags!
      const $form = railsService.createMethodFormElement $attrs, $rootScope

      expect $form.prop('tagName') .toBe 'FORM'
      expect $form.scope! .toBeDefined!

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

  describe 'noopConfirmCtrl' !(...) ->
    
    it 'should be defined' !(...) ->
      expect railsService.noopConfirmCtrl .toBeDefined!

    it 'should be created with new' !(...) ->
      expect new railsService.noopConfirmCtrl .toBeDefined!

    it 'should return controller like RailsConfirmCtrl' !(...) ->
      const noopCtrl = new railsService.noopConfirmCtrl
      
      expect noopCtrl.allowAction .toBeDefined!
      expect noopCtrl.denyDefaultAction .toBeDefined!
      expect noopCtrl.allowAction! .toBeTruthy!

describe 'RailsConfirmCtrl' !(...) ->
  railsConfirmCtrl = confirmSpy = $scope = void

  beforeEach inject !($controller) ->
    $scope            := $rootScope.$new!
    railsConfirmCtrl  := $controller 'RailsConfirmCtrl' {$scope}
    confirmSpy        := spyOn window, 'confirm'

  afterEach !(...) ->
    $scope.$destroy!

  it 'should have a denyDefaultAction method' !(...) ->
    expect railsConfirmCtrl.denyDefaultAction .toBeDefined!

  it 'should supress event when denyDefaultAction called' !(...) ->
    const event = $.Event 'click'
    railsConfirmCtrl.denyDefaultAction event

    expect event.isDefaultPrevented! .toBeTruthy!
    expect event.isPropagationStopped! .toBeTruthy!

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

  it 'should allow action when message provided' !(...) ->
    confirmSpy := confirmSpy.andReturn true
    const $attrs = do
      confirm: 'iMessage'

    expect railsConfirmCtrl.allowAction($attrs) .toBeTruthy!
    expect confirmSpy .toHaveBeenCalled!


describe 'RailsRemoteFormCtrl' !(...) ->
  railsRemoteFormCtrl = $scope = void

  beforeEach inject !($controller) ->
    $scope              := $rootScope.$new!
    railsRemoteFormCtrl := $controller 'RailsRemoteFormCtrl' {$scope}

  afterEach !(...) ->
    $scope.$destroy!

  it 'should have a submit method' !(...) ->
    expect railsRemoteFormCtrl.submit .toBeDefined!

  it 'should submit form using $http' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    
    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users">
        <input ng-model="user.name" type="text">
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!

    railsRemoteFormCtrl.submit $element, 'user'
    $httpBackend.flush!
    $element.remove!

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
    $element.remove!

describe 'remote directive' !(...) ->
  $scope = void

  beforeEach !(...) ->
    $scope       := $rootScope.$new!

  afterEach !(...) ->
    $scope.$destroy!

  it "shouldn't activate without 'data-' prefix" !(...) ->    
    const $element = $compile('''
      <form method="POST" action="/users" remote="user">
        <input type='submit'>
      </form>
    ''')($scope)
    $document.find 'body' .append $element
    
    $element.on 'submit' !(event) ->
      expect event.defaultPrevented .toBeFalsy!
      event.preventDefault!
      event.stopPropagation!
      $element.remove!

    $element.find 'input' .eq 1 .click!

  it 'should submit using $http for form element' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const confirmSpy = spyOn window, 'confirm'
    
    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
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
    $element.remove!

  it 'should work with confirm directive' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    spyOn window, 'confirm' .andReturn true
    
    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users" data-confirm="Are u sure?" data-remote="user">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!
    
    $element.find 'input' .eq 1 .click!
    $httpBackend.flush!
    $element.remove!


describe 'method directive' !(...) ->
  $scope = void

  beforeEach !(...) ->
    $scope       := $rootScope.$new!

  afterEach !(...) ->
    $scope.$destroy!

  it "shouldn't activate without 'data-' prefix" !(...) ->
    clicked = false
    runs !->
      const $element = $compile('''
        <a href="/users/sign_out" method="DELETE">SignOut</a>
      ''')($scope)
      $document.find 'body' .append $element
      
      $element.on 'click' !(event) ->
        event.preventDefault!
        event.stopPropagation!
        $element.remove!
        clicked := true

      $element.click!

    waitsFor ->
      clicked
    , 'anchor should be clicked', 500

describe 'method directive with remote directive' !(...) ->
  $scope = void

  beforeEach inject !($controller) ->
    $scope       := $rootScope.$new!

  afterEach !(...) ->
    $scope.$destroy!

  it "should submit with remote form" !(...) ->
    response = false
    runs !->
      $httpBackend.expectPOST '/users/sign_out' do
        _method: 'DELETE'
      .respond 201

      const $element = $compile('''
        <a href="/users/sign_out" data-method="DELETE" data-remote="true">SignOut</a>
      ''')($scope)
      $document.find 'body' .append $element

      $scope.$on 'rails:remote:success' !->
        response := true

      $element.click!
      $httpBackend.flush!

    waitsFor ->
      response
    , 'response should be returned', 500

  it 'should work with confirm and remote form' !(...) ->
    response = false

    runs !->
      spyOn window, 'confirm' .andReturn true
      $httpBackend.expectPOST '/users/sign_out' do
        _method: 'DELETE'
      .respond 201

      const $element = $compile('''
        <a href="/users/sign_out" data-method="DELETE" data-remote="true" data-confirm="Are u sure?">SignOut</a>
      ''')($scope)
      $document.find 'body' .append $element

      $scope.$on 'rails:remote:success' !->
        response := true

      $element.click!
      $httpBackend.flush!

    waitsFor ->
      response
    , 'response should be returned', 500










