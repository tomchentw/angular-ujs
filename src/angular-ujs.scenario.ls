(...) <-! describe 'angular-ujs'
const ptor = protractor.getInstance!

it 'should work' !(...) ->
  ptor.get '/'
  # ptor.wait 5000
  expect element(by.id('home_index')).getText! .toBe 'Home#index'

it 'should sign up' !(...) ->
  ptor.get '/users/sign_up'

  element(by.model 'user.email').sendKeys 'developer@tomchentw.com'
  element(by.model 'user.password').sendKeys 'angular-ujs'
  element(by.model 'user.password_confirmation').sendKeys 'angular-ujs'
  element(by.css 'input[name="commit"]').click!

  browser.driver.sleep 500
  expect element(by.binding 'success').getText! .toBe 'Yo!'
