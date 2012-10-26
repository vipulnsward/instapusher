# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hpusher/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Neeraj Singh"]
  gem.email         = ["neeraj@bigbinary.com"]
  gem.description   = %q{hpusher makes it easy to push code to heroku}
  gem.summary       = %q{hpusher gem makes it easy to push code to heroku}
  gem.homepage      = "http://bigbinary.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hpusher"
  gem.require_paths = ["lib"]
  gem.version       = Hpusher::VERSION

  gem.add_dependency("hashr", "= 0.0.19")
  gem.add_dependency("heroku", "= 2.25.0")
end
