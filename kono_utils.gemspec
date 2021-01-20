$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kono_utils/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "kono_utils"
  s.version = KonoUtils::VERSION
  s.authors = ["Marino"]
  s.email = ["marino.bonetti@archimedianet.it"]
  s.homepage = "https://github.com/ArchimediaZerogroup/KonoUtils"
  s.summary = "Kono Utilities"
  s.description = "Gemma per che raccoglie varie tipologie di classi di utilità varia che possono servire al funzionamento delle applicazioni e semplificare la vita al programmatore Rails"
  s.license = "MIT"

  files = `git ls-files -z`.split("\x0")

  s.files = files.grep(%r{^(lib|app|vendor|config)/}) + %w(MIT-LICENSE Rakefile README.rdoc)

  s.test_files = files.grep(%r{^(spec)/})

  s.add_dependency 'actionview'
  s.add_dependency 'rdiscount' #serve per stampare il markdown del changelog
  s.add_dependency 'coffee-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'pundit', '~> 2.0'
  s.add_dependency 'kono_utils_helpers'
  s.add_dependency 'active_type'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rails', '> 4.2.4'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'listen'

end
