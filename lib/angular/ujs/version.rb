require 'json'

module Angular
  module Ujs
    VERSION = JSON.parse(File.read('package.json'))['version']
  end
end
