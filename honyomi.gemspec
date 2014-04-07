# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'honyomi/version'

Gem::Specification.new do |spec|
  spec.name          = "honyomi"
  spec.version       = Honyomi::VERSION
  spec.authors       = ["ongaeshi"]
  spec.email         = ["ongaeshi0621@gmail.com"]
  spec.summary       = %q{e-book (pdf) search engine, command line interface, and web application}
  spec.description   = %q{honyomi is a e-book (pdf) search engine. It have command line interface and web application. It will accelerate the e-book of your life.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).find_all {|f| f !~ /\Aimages\// }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'grn_mini', "~> 0.5"
  spec.add_dependency 'haml'
  spec.add_dependency 'launchy'
  spec.add_dependency 'rack'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'thin', "< 1.7"
  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency 'sinatra-reloader'
end
