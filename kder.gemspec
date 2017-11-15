# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryan Taylor", "Logan Bowers"]
  gem.email         = ["ryanmt@byu.net", "logan@datacurrent.com"]
  gem.description   = %q{A KDE implementation in Ruby.}
  gem.summary       = %q{Kernel Density Estimation, and an associated bandwidth estimator, rudimentary at best, but a decent first approximation for backend preparing of KDE plots for plotting in JS libraries, or for whatever you would like to use it.}
  gem.homepage      = "https://github.com/loganb/KDER"

  gem.files         = Dir["lib/**/*.rb"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "loganb-kder"
  gem.version       = Kder::VERSION
end
