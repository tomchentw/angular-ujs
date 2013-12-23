# angular-ujs ( Angular::Ujs )

Ruby on Rails unobtrusive scripting adapter for angularjs ( Without jQuery dependency )

## Project philosophy

### Native, lightweight directives
Unobtrusive scripting provides the same interface with angular directives, this project makes use of the similarity and provides seamless intergration with `jquery_ujs`.  
Further improvements through PRs are welcome.

## Installation

This project follows **DRY** and has one dependency on [`ng-rails-csrf`](https://github.com/xrd/ng-rails-csrf/).

### Simple front-end usage

* Download and include [`ng-rails-csrf.js`](https://github.com/xrd/ng-rails-csrf/blob/master/vendor/assets/javascripts/ng-rails-csrf.js).
* Download and include [`angular-ujs.js`](https://github.com/tomchentw/angular-ujs/blob/master/angular-ujs.js) OR [`angular-ujs.min.js`](https://github.com/tomchentw/angular-ujs/blob/master/angular-ujs.min.js).  
Then include them through script tag in your HTML.

### Rails projects

Add these line to your application's Gemfile:

    gem 'ng-rails-csrf'
    gem 'angular-ujs'

And then execute:

    $ bundle

We only support Rails 3.1+, add these lines to the top of your `app/assets/javascripts/application.js` file:

```javascript
//= require angular
//= require ng-rails-csrf
//= require angular-ujs
```

### Ruby gem only

    $ gem install ng-rails-csrf angular-ujs

## [Usage](https://github.com/tomchentw/angular-ujs/blob/master/src/README.md)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
