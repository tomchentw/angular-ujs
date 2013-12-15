# angular-ujs ( Angular::Ujs )

Ruby on Rails unobtrusive scripting adapter for angularjs ( Without jQuery dependency )

## Installation

### Simple front-end usage

Download [`angular-ujs.js`](https://github.com/tomchentw/angular-ujs/blob/master/angular-ujs.js) OR [`angular-ujs.min.js`](https://github.com/tomchentw/angular-ujs/blob/master/angular-ujs.min.js) in ROOT.  
Then include it through script tag.

### For Rails project

Add this line to your application's Gemfile:

    gem 'angular-ujs'

And then execute:

    $ bundle

We only support Rails 3.1+, add these lines to the top of your `app/assets/javascripts/application.js` file:

```javascript
//= require angular
//= require angular-ujs
```

### Ruby gem only

    $ gem install angular-ujs

## Usage

See [Wiki Page](https://github.com/tomchentw/angular-ujs/wiki)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
