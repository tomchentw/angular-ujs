# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'angular/ujs/package'

Gem::Specification.new do |spec|
  spec.name          = Angular::Ujs::NAME
  spec.version       = Angular::Ujs::VERSION
  spec.authors       = [Angular::Ujs::AUTHOR["name"]]
  spec.email         = [Angular::Ujs::AUTHOR["email"]]
  spec.description   = Angular::Ujs::DESCRIPTION
  spec.summary       = Angular::Ujs::SUMMARY
  spec.homepage      = Angular::Ujs::HOMEPAGE
  spec.license       = Angular::Ujs::LICENSE["type"]

  spec.files         = ["package.json", "LICENSE", "README.md"] + Dir["lib/**/*.rb"] + Dir["vendor/assets/javascripts/*.js"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "railties", ">= 3.1"
  spec.add_runtime_dependency "ng-rails-csrf", "~> 0.1.0"
end
