(...) <-! describe 'angular-ujs'
const ptor = protractor.getInstance!

it 'should work' !(...) ->
  ptor.get '/'
  # ptor.wait 5000
  expect element(by.id('home_index')).getText! .toBe 'Home#index'