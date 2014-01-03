(...) <-! describe 'angular-ujs'
const ptor = protractor.getInstance!
ROOT_URL = void

!function matchPath(path)
  const promise = if typeof! path is 'String'
    ROOT_URL.then (root) -> "#{ root }#{ path }"
  else path or ROOT_URL

  expect browser.driver.getCurrentUrl! .toBe promise 

it 'should work' !(...) ->
  ptor.get '/'
  # ptor.wait 5000
  expect element(by.id('home_index')).getText! .toBe 'Home#index'
  ROOT_URL := browser.driver.getCurrentUrl!

  expect ROOT_URL .toBeDefined!

describe 'confirm, remote, method directives normal functions' !(...) ->

  it 'should sign up' !(...) ->
    ptor.get '/users/sign_up'

    element(by.model 'user.email').sendKeys 'developer@tomchentw.com'
    element(by.model 'user.password').sendKeys 'angular-ujs'
    element(by.model 'user.password_confirmation').sendKeys 'angular-ujs'
    element(by.css 'input[name="commit"]').click!

    browser.driver.sleep 500
    expect element(by.binding 'success').getText! .toBe 'Yo!'

  it 'should sign out' !(...) ->
    element(by.id 'sign_out').click!
    
    browser.driver.sleep 500
    matchPath!

  it 'should confirm and sign in' !(...) ->
    ptor.get '/users/sign_in'

    element(by.model 'user.email').sendKeys 'developer@tomchentw.com'
    element(by.model 'user.password').sendKeys 'angular-ujs'
    element(by.css 'input[name="commit"]').click!

    browser.driver.switchTo!alert!accept!

    browser.driver.sleep 500
    expect element(by.binding 'success').getText! .toBe 'Yo!'

  it 'should confirm and sign out' !(...) ->
    element(by.id 'sign_out').click!
    browser.driver.switchTo!alert!accept!
    
    browser.driver.sleep 500
    matchPath!

  it 'should work together' !(...) ->
    element(by.id 'work_together').click!
    browser.driver.switchTo!alert!accept!
    
    browser.driver.sleep 500
    expect element(by.binding 'success').getText! .toBe 'Yo!'
    
describe 'confirm directive' !(...) ->
  it 'should greet and one dismiss it' !(...) ->
    element(by.id 'hello_world').click!
    browser.driver.switchTo!alert!dismiss!

    browser.driver.sleep 500
    matchPath!

  it 'should greet and one accept it' !(...) ->
    element(by.id 'hello_world').click!
    browser.driver.switchTo!alert!accept!

    browser.driver.sleep 500
    matchPath 'users/sign_in'
