# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'angular/ujs/version'

Gem::Specification.new do |spec|
  spec.name          = "angular-ujs"
  spec.version       = Angular::Ujs::VERSION
  spec.authors       = ["tomchentw"]
  spec.email         = ["developer@tomchentw.com"]
  spec.description   = %q{Unobtrusive scripting adapter for angularjs}
  spec.summary       = %q{Ruby on Rails unobtrusive scripting adapter for angularjs ( Without jQuery dependency )}
  spec.homepage      = "https://github.com/tomchentw/angular-ujs"
  spec.license       = "MIT"

  spec.files         = ["LICENSE", "README.md"] + Dir["lib/**/*.rb"] + Dir["vendor/assets/javascripts/*.js"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "railties", "~> 3.1"
  spec.add_runtime_dependency "ng-rails-csrf", "~> 0.1.0"
end
