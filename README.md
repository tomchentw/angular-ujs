# angular-ujs
> Distributed via

[![Version     ](http://img.shields.io/gem/v/angular-ujs.svg)                                     ](https://rubygems.org/gems/angular-ujs)

> Unobtrusive scripting for AngularJS ( without jQuery dependency )

[![Travis CI   ](http://img.shields.io/travis/tomchentw/angular-ujs/master.svg)                   ](https://travis-ci.org/tomchentw/angular-ujs)
[![Quality     ](http://img.shields.io/codeclimate/github/tomchentw/angular-ujs.svg)              ](https://codeclimate.com/github/tomchentw/angular-ujs)
[![Coverage    ](http://img.shields.io/coveralls/tomchentw/angular-ujs.svg)                       ](https://coveralls.io/r/tomchentw/angular-ujs)
[![Dependencies](http://img.shields.io/gemnasium/tomchentw/angular-ujs.svg)                       ](https://gemnasium.com/tomchentw/angular-ujs)


## Project philosophy

### Develop in LiveScript
[LiveScript](http://livescript.net/) is a compile-to-js language, which provides us more robust way to write JavaScript.  
It also has great readibility and lots of syntax sugar just like you're writting python/ruby.

### Native, lightweight directives
Unobtrusive scripting in `jquery_ujs` provides the same interface with angular `directives`.  
We use the similarity between them and provides seamless intergration with `jquery_ujs`.  

### Spec / Scenario coverage
We use `krama` to run unit test against [angular-ujs.spec.ls](https://github.com/tomchentw/angular-ujs/blob/master/src/angular-ujs.spec.ls) and use `protractor` to run intergration test via [angular-ujs.scenario.ls](https://github.com/tomchentw/angular-ujs/blob/master/src/angular-ujs.scenario.ls).


## Installation

We follow **DRY** and has one dependency only on `angularjs`.  
However, we recommend you add [`ng-rails-csrf`](https://github.com/xrd/ng-rails-csrf/) into your project. As it name suggests, `ng-rails-csrf` automatically resolves CSRF in `angularjs` environment without `jquery_ujs`.

### Just use it

* (_Optional_) Download and include [`ng-rails-csrf.js`](https://github.com/xrd/ng-rails-csrf/blob/master/vendor/assets/javascripts/ng-rails-csrf.js).
* Download and include [`angular-ujs.js`](https://github.com/tomchentw/angular-ujs/blob/master/angular-ujs.js) OR [`angular-ujs.min.js`](https://github.com/tomchentw/angular-ujs/blob/master/angular-ujs.min.js).  

Then include them through script tag in your HTML.

### **Rails** projects (Only support 3.1+)
Add this line to your application's Gemfile:
```ruby
gem 'ng-rails-csrf' # Optional
gem 'angular-ujs'
```

And then execute:

    $ bundle

Then add these lines to the top of your `app/assets/javascripts/application.js` file:

```javascript
//= require angular
//= require ng-rails-csrf (Optional)
//= require angular-ujs
```

And include in your `angular` module definition:
    
    /* 'angular.ujs' DO NOT depend on 'ng-rails-csrf' module.
     * You need to include it yourself.
     */    
    var module = angular.module('my-awesome-project', ['angular.ujs']).



## Usage

### "data-confirm": Confirmation dialogs for links and forms

```html
<form data-confirm="Are you sure you want to submit?">...</form>
```

### "data-method": Links that result in POST, PUT, or DELETE requests

```html
<a href="..." data-method="delete" rel="nofollow">Delete this entry</a>
```

### "data-remote": Make links and forms submit asynchronously with Ajax
** Notice : API changed **

For `angularjs` apps, **ONLY** those items with `ng-model` will be submitted with `data-remote`

```html
<form data-remote="true" action="...">
  <input type="text" name="name" ng-model="name">
</form>
```

#### You can specify the model name via `data-remote` :
```html
<form data-remote="user" action="...">
  <input type="text" name="name" ng-model="user.name">
  <input type="email" name="email" ng-model="user.email">
</form>
```

### Use them all together :

```html
<a href="..." data-method="delete" data-remote="true" data-confirm="Are you sure you want to delete?" rel="nofollow">Delete this entry</a>
```


## Contributing

[![devDependency Status](https://david-dm.org/tomchentw/angular-ujs/dev-status.svg?theme=shields.io)](https://david-dm.org/tomchentw/angular-ujs#info=devDependencies)

1. Fork it ( http://github.com/tomchentw/angular-ujs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
