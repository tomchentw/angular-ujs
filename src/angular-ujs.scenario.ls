(...) <-! describe 'angular-ujs'
const ptor = protractor.getInstance!
ROOT_URL = void

it 'should work' !(...) ->
  ptor.get '/'
  # ptor.wait 5000
  expect element(by.id('home_index')).getText! .toBe 'Home#index'
  ROOT_URL := browser.driver.getCurrentUrl!

  expect ROOT_URL .toBeDefined!

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

  expect browser.driver.getCurrentUrl! .toBe ROOT_URL

it 'should confirm and sign in' !(...) ->
  ptor.get '/users/sign_in'

  element(by.model 'user.email').sendKeys 'developer@tomchentw.com'
  element(by.model 'user.password').sendKeys 'angular-ujs'
  element(by.css 'input[name="commit"]').click!

  browser.driver.sleep 500
  browser.driver.switchTo!alert!accept!

  browser.driver.sleep 500
  expect element(by.binding 'success').getText! .toBe 'Yo!'